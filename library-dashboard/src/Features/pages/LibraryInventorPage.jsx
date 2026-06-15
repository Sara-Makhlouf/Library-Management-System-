import {
  Box,
  Typography,
  TextField,
  Select,
  MenuItem,
  Button,
  Avatar,
  Chip,
  IconButton,
  Tooltip,
  InputAdornment,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Pagination,
} from "@mui/material";
import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { AnimatePresence, motion } from "framer-motion";

import AutoStoriesIcon        from "@mui/icons-material/AutoStories";
import DeleteOutlineIcon      from "@mui/icons-material/DeleteOutline";
import SwapHorizIcon          from "@mui/icons-material/SwapHoriz";
import AddIcon                from "@mui/icons-material/Add";
import SearchIcon             from "@mui/icons-material/Search";
import CategoryOutlinedIcon   from "@mui/icons-material/CategoryOutlined";
import MenuBookOutlinedIcon   from "@mui/icons-material/MenuBookOutlined";
import LayersOutlinedIcon     from "@mui/icons-material/LayersOutlined";
import CheckCircleOutlineIcon from "@mui/icons-material/CheckCircleOutline";
import EditIcon               from "@mui/icons-material/Edit";
import TrendingUpIcon         from "@mui/icons-material/TrendingUp";

import { fetchBooks, deletBooks, updateBooks } from "../../Core/Redux/Thunks/BookThunk";
import AddBookPage from "./AddNewBook";


const BG       = "#0a0a0f";
const SURFACE  = "#111118";
const GOLD     = "#c9a84c";
const GOLD_DIM = "#8b5e1a";
const BORDER   = "rgba(255,255,255,0.06)";
const TEXT     = "#fff";
const MUTED    = "rgba(255,255,255,0.35)";
const MUTED2   = "rgba(255,255,255,0.20)";

const IMAGE_BASE_URL = "http://localhost:8000/storage/";

const KPI = [
  { label: "Total Books", icon: <MenuBookOutlinedIcon  sx={{ fontSize: 16 }} />, accent: GOLD,      trend: "all time" },
  { label: "This Page",   icon: <CheckCircleOutlineIcon sx={{ fontSize: 16 }} />, accent: "#97c459", trend: "current view" },
  { label: "Total Pages", icon: <LayersOutlinedIcon    sx={{ fontSize: 16 }} />, accent: "#7f77dd", trend: "paginated" },
];

function StockBar({ stock, max, accent }) {
  const pct = max > 0 ? Math.round((stock / max) * 100) : 0;
  return (
    <Box sx={{ height: 3, borderRadius: 2, bgcolor: "rgba(255,255,255,0.07)", overflow: "hidden", mt: 1.5 }}>
      <Box sx={{ height: "100%", width: `${pct}%`, bgcolor: accent, borderRadius: 2, transition: "width 0.4s ease" }} />
    </Box>
  );
}

export default function LibraryInventoryPage() {
  const dispatch = useDispatch();

  const booksData   = useSelector((state) => state.books.books) || {};
  const books       = booksData.data         || [];
  const totalPages  = booksData.last_page    || 1;
  const currentPage = booksData.current_page || 1;
  const loading     = useSelector((state) => state.books.loading);

  const [search,   setSearch]   = useState("");
  const [genre,    setGenre]    = useState("");
  const [status]                = useState("");
  const [openAdd,  setOpenAdd]  = useState(false);
  const [editBook, setEditBook] = useState(null);
  const [editForm, setEditForm] = useState({ title: "", price: "", sale_price: "" });

  useEffect(() => { dispatch(fetchBooks(1)); }, [dispatch]);

  const handlePageChange = (_, value) => {
    dispatch(fetchBooks(value));
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to delete this book?")) return;
    try {
      await dispatch(deletBooks(id)).unwrap();
      dispatch(fetchBooks(currentPage));
    } catch (err) { console.error(err); }
  };

  const handleToggleStatus = async (book) => {
    const updated = { ...book, stock: book.stock > 0 ? 0 : 5 };
    await dispatch(updateBooks({ bookId: book.id, bookData: updated }));
    dispatch(fetchBooks(currentPage));
  };

const handleOpenEdit = (book) => {
  if (!book) return; 
  setEditBook(book);
  setEditForm({ 
    title: book.title || "", 
    price: book.price || 0, 
    sale_price: book.sale_price || 0 
  });
};
  const handleSaveEdit = async () => {
    try {
      await dispatch(updateBooks({ bookId: editBook.id, bookData: editForm })).unwrap();
      setEditBook(null);
      dispatch(fetchBooks(currentPage));
    } catch (err) { console.error(err); }
  };

const filteredBooks = Array.isArray(books) ? books.filter((book) => {
  if (!book) return false; 
  
  const searchLower = search.toLowerCase();
  const matchSearch = 
    book.title?.toLowerCase().includes(searchLower) ||
    book.authors?.some((a) => a.name.toLowerCase().includes(searchLower));
    
  const matchGenre = genre ? book.category?.name === genre : true;
  const matchStatus = status === "" ? true : status === "Available" ? book.stock > 0 : book.stock === 0;
  
  return matchSearch && matchGenre && matchStatus;
}) : [];

const maxStock = filteredBooks.length > 0 
  ? Math.max(...filteredBooks.map((b) => b.stock || 0)) 
  : 0;
  if (loading) {
    return (
      <Box sx={{ minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", bgcolor: BG }}>
        <CircularProgress sx={{ color: GOLD }} />
      </Box>
    );
  }

  return (
    <Box sx={{ minHeight: "100vh", bgcolor: BG, p: { xs: 2, md: "20px 24px" }, fontFamily: "Inter, sans-serif" }}>

      <Box
        sx={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          mb: 3, px: "20px", height: 60,
          bgcolor: "rgba(255,255,255,0.04)",
          border: `1px solid ${BORDER}`,
          borderRadius: "16px",
          position: "sticky", top: 0, zIndex: 10,
          backdropFilter: "blur(16px)",
        }}
      >
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5 }}>
          <Box
            sx={{
              width: 32, height: 32, borderRadius: "10px",
              background: `linear-gradient(135deg,${GOLD},${GOLD_DIM})`,
              display: "flex", alignItems: "center", justifyContent: "center",
            }}
          >
            <AutoStoriesIcon sx={{ fontSize: 17, color: "#fff" }} />
          </Box>
          <Typography sx={{ fontWeight: 700, fontSize: 15, color: TEXT, letterSpacing: -0.3 }}>
            Library Inventory
          </Typography>
        </Box>

        <Button
          startIcon={<AddIcon sx={{ fontSize: 15 }} />}
          onClick={() => setOpenAdd(true)}
          sx={{
            px: 2.5, py: 0.9, borderRadius: "10px",
            fontWeight: 700, textTransform: "none", fontSize: 13,
            color: "#fff",
            background: `linear-gradient(135deg,${GOLD},${GOLD_DIM})`,
            "&:hover": {
              background: `linear-gradient(135deg,#d4b562,#9e6c20)`,
              transform: "translateY(-1px)",
              boxShadow: "0 12px 28px rgba(201,168,76,0.25)",
            },
            transition: "all 0.25s",
          }}
        >
          Add New Book
        </Button>
      </Box>

      <Box
        sx={{
          p: { xs: 3, md: "36px 40px" },
          borderRadius: "20px",
          background: "linear-gradient(135deg,#111118 0%,#1a1206 100%)",
          border: "1px solid rgba(201,168,76,0.2)",
          position: "relative", overflow: "hidden",
          mb: 2.5,
        }}
      >
        <Box sx={{ position: "absolute", top: -100, right: -80, width: 300, height: 300, background: "radial-gradient(circle,rgba(201,168,76,0.08) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: -60, left: -40, width: 200, height: 200, background: "radial-gradient(circle,rgba(139,94,26,0.06) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

        <Chip
          label="● Inventory System"
          size="small"
          sx={{
            mb: 2.5,
            bgcolor: "rgba(201,168,76,0.1)",
            border: "1px solid rgba(201,168,76,0.2)",
            color: GOLD, fontWeight: 600, fontSize: 11,
            letterSpacing: 0.5, height: 24, borderRadius: "20px",
            "& .MuiChip-label": { px: 1.5 },
          }}
        />

        <Typography
          sx={{
            fontSize: { xs: 24, md: 32 }, fontWeight: 800,
            letterSpacing: -1, lineHeight: 1.1, mb: 1.5,
            background: `linear-gradient(135deg,${TEXT} 0%,${GOLD} 100%)`,
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text",
          }}
        >
          Manage your book collection
        </Typography>

        <Typography sx={{ fontSize: 14, color: "rgba(255,255,255,0.45)", lineHeight: 1.7, maxWidth: 440 }}>
          Search, filter, edit, and track stock levels across your entire library in one unified view.
        </Typography>
      </Box>

      <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr 1fr", md: "repeat(3,1fr)" }, gap: 2, mb: 2.5 }}>
        {[
          { ...KPI[0], value: booksData.total || 0 },
          { ...KPI[1], value: books.length },
          { ...KPI[2], value: totalPages },
        ].map((item) => (
          <Box
            key={item.label}
            component={motion.div}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            sx={{
              p: "20px", borderRadius: "18px",
              bgcolor: SURFACE, border: `1px solid ${BORDER}`,
              cursor: "pointer", transition: "all 0.25s",
              "&:hover": { borderColor: `${item.accent}40`, transform: "translateY(-3px)", bgcolor: "#151520" },
            }}
          >
            <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 1.5 }}>
              <Typography sx={{ fontSize: 11, fontWeight: 600, color: MUTED, letterSpacing: "0.8px", textTransform: "uppercase" }}>
                {item.label}
              </Typography>
              <Box sx={{ width: 28, height: 28, borderRadius: "8px", bgcolor: `${item.accent}18`, color: item.accent, display: "flex", alignItems: "center", justifyContent: "center" }}>
                {item.icon}
              </Box>
            </Box>
            <Typography sx={{ fontSize: 28, fontWeight: 800, letterSpacing: -1, color: TEXT, mb: 0.5 }}>
              {Number(item.value).toLocaleString()}
            </Typography>
            <Typography sx={{ fontSize: 11, color: item.accent, display: "flex", alignItems: "center", gap: 0.3 }}>
              <TrendingUpIcon sx={{ fontSize: 12 }} /> {item.trend}
            </Typography>
          </Box>
        ))}
      </Box>

    
      <Box
        sx={{
          p: "14px 18px", mb: 2.5,
          borderRadius: "16px",
          bgcolor: SURFACE,
          border: `1px solid ${BORDER}`,
          display: "flex", gap: 1.5, flexWrap: "wrap", alignItems: "center",
        }}
      >
        <TextField
          placeholder="Search books or authors…"
          size="small"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon sx={{ fontSize: 17, color: MUTED2 }} />
              </InputAdornment>
            ),
          }}
          sx={{
            flex: { xs: "100%", md: 2 },
            "& .MuiOutlinedInput-root": {
              borderRadius: "10px", fontSize: 13.5,
              bgcolor: "rgba(255,255,255,0.04)", color: TEXT,
              "& fieldset": { borderColor: BORDER },
              "&:hover fieldset": { borderColor: "rgba(255,255,255,0.12)" },
              "&.Mui-focused fieldset": { borderColor: `${GOLD}60` },
            },
            "& input::placeholder": { color: MUTED, opacity: 1 },
            "& input": { color: TEXT },
          }}
        />

        <Select
          size="small"
          value={genre}
          onChange={(e) => setGenre(e.target.value)}
          displayEmpty
          startAdornment={<CategoryOutlinedIcon sx={{ fontSize: 16, color: MUTED2, mr: 0.5 }} />}
          sx={{
            flex: { xs: "100%", sm: 1 },
            borderRadius: "10px", fontSize: 13.5,
            bgcolor: "rgba(255,255,255,0.04)", color: TEXT,
            "& fieldset": { borderColor: BORDER },
            "& .MuiSelect-icon": { color: MUTED2 },
            "&:hover fieldset": { borderColor: "rgba(255,255,255,0.12)" },
          }}
          MenuProps={{ PaperProps: { sx: { bgcolor: "#1a1a24", border: `1px solid ${BORDER}`, color: TEXT } } }}
        >
          <MenuItem value="">All Genres</MenuItem>
          <MenuItem value="روايات">Novels / روايات</MenuItem>
          <MenuItem value="تكنولوجيا">Technology / تكنولوجيا</MenuItem>
          <MenuItem value="تاريخ">History / تاريخ</MenuItem>
          <MenuItem value="علوم">Science / علوم</MenuItem>
          <MenuItem value="فلسفة">Philosophy / فلسفة</MenuItem>
        </Select>
      </Box>

      <Box sx={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))", gap: 2, mb: 3 }}>
        <AnimatePresence mode="wait">
          {filteredBooks.map((book) => (
            <Box
              key={book.id}
              component={motion.div}
              layout
              initial={{ opacity: 0, scale: 0.96 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.96 }}
              transition={{ duration: 0.18 }}
            >
              <Box
                sx={{
                  borderRadius: "18px",
                  bgcolor: SURFACE,
                  border: `1px solid ${BORDER}`,
                  overflow: "hidden",
                  display: "flex", flexDirection: "column",
                  transition: "all 0.25s",
                  cursor: "pointer",
                  "&:hover": {
                    borderColor: `${GOLD}40`,
                    transform: "translateY(-3px)",
                    bgcolor: "#151520",
                  },
                }}
              >
                <Box sx={{ aspectRatio: "3/2", bgcolor: "rgba(255,255,255,0.02)", position: "relative", overflow: "hidden" }}>
                  <Avatar
                    src={book.cover ? `${IMAGE_BASE_URL}${book.cover}` : "/history book.jpg"}
                    variant="square"
                    sx={{ width: "100%", height: "100%", objectFit: "cover" }}
                  />
                  <Box
                    sx={{
                      position: "absolute", top: 10, right: 10,
                      px: 1.2, py: 0.3, borderRadius: "6px",
                      bgcolor: book.stock > 0 ? "rgba(74,222,128,0.12)" : "rgba(239,68,68,0.12)",
                    }}
                  >
                    <Typography sx={{ fontSize: 10, fontWeight: 700, letterSpacing: 0.5, color: book.stock > 0 ? "#4ade80" : "#f87171" }}>
                      {book.stock > 0 ? `STOCK ${book.stock}` : "OUT OF STOCK"}
                    </Typography>
                  </Box>
                </Box>

                <Box sx={{ p: "14px 16px", flex: 1, display: "flex", flexDirection: "column" }}>
                  <Typography sx={{ fontWeight: 700, fontSize: 13.5, color: TEXT, mb: 0.3, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                    {book.title}
                  </Typography>
                  <Typography sx={{ fontSize: 11.5, color: MUTED, mb: 1.5, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                    {book.authors?.map((a) => a.name).join(", ") || "Unknown Author"}
                  </Typography>

                  <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 1 }}>
                    <Box
                      sx={{
                        px: 1.2, py: 0.3, borderRadius: "6px",
                        bgcolor: "rgba(201,168,76,0.1)",
                        border: "1px solid rgba(201,168,76,0.15)",
                      }}
                    >
                      <Typography sx={{ fontSize: 10, fontWeight: 700, color: GOLD, letterSpacing: 0.4 }}>
                        {book.category?.name || "General"}
                      </Typography>
                    </Box>

                    <Typography sx={{ fontSize: 13, fontWeight: 800, color: GOLD, letterSpacing: -0.3 }}>
                      {Number(book.sale_price).toLocaleString()}
                      <Box component="span" sx={{ fontSize: 10, fontWeight: 400, color: MUTED, ml: 0.4 }}>SAR</Box>
                    </Typography>
                  </Box>

                  <Typography sx={{ fontSize: 11, color: MUTED2, mb: 1.5 }}>
                    Cost: {Number(book.price).toLocaleString()} · Sale: {Number(book.sale_price).toLocaleString()}
                  </Typography>

                  <StockBar stock={book.stock || 0} max={maxStock} accent={GOLD} />

                  <Box
                    sx={{
                      display: "flex", gap: 1, mt: 2,
                      pt: 1.5, borderTop: "1px solid rgba(255,255,255,0.05)",
                    }}
                  >
                    <Button
                      size="small"
                      startIcon={<SwapHorizIcon sx={{ fontSize: 13 }} />}
                      onClick={() => handleToggleStatus(book)}
                      sx={{
                        flex: 1, borderRadius: "8px", textTransform: "none",
                        fontSize: 12, fontWeight: 600,
                        color: "rgba(255,255,255,0.5)",
                        border: `1px solid ${BORDER}`,
                        bgcolor: "rgba(255,255,255,0.03)",
                        "&:hover": { bgcolor: "rgba(255,255,255,0.07)", color: TEXT, borderColor: "rgba(255,255,255,0.12)" },
                        transition: "all 0.2s",
                      }}
                    >
                      Status
                    </Button>

                    <Tooltip title="Edit" arrow>
                      <IconButton
                        size="small"
                        onClick={() => handleOpenEdit(book)}
                        sx={{
                          borderRadius: "8px",
                          border: `1px solid ${BORDER}`,
                          bgcolor: "rgba(255,255,255,0.03)",
                          color: "#7f77dd",
                          "&:hover": { bgcolor: "rgba(127,119,221,0.1)", borderColor: "rgba(127,119,221,0.3)" },
                          transition: "all 0.2s",
                        }}
                      >
                        <EditIcon sx={{ fontSize: 15 }} />
                      </IconButton>
                    </Tooltip>

                    <Tooltip title="Delete" arrow>
                      <IconButton
                        size="small"
                        onClick={() => handleDelete(book.id)}
                        sx={{
                          borderRadius: "8px",
                          border: `1px solid ${BORDER}`,
                          bgcolor: "rgba(255,255,255,0.03)",
                          color: "#f87171",
                          "&:hover": { bgcolor: "rgba(248,113,113,0.1)", borderColor: "rgba(248,113,113,0.3)" },
                          transition: "all 0.2s",
                        }}
                      >
                        <DeleteOutlineIcon sx={{ fontSize: 15 }} />
                      </IconButton>
                    </Tooltip>
                  </Box>
                </Box>
              </Box>
            </Box>
          ))}
        </AnimatePresence>
      </Box>

      <Box sx={{ display: "flex", justifyContent: "center", pb: 4 }}>
        <Pagination
          count={totalPages}
          page={currentPage}
          onChange={handlePageChange}
          size="medium"
          sx={{
            "& .MuiPaginationItem-root": {
              borderRadius: "8px", fontWeight: 700, fontSize: 13,
              color: MUTED, border: `1px solid ${BORDER}`, bgcolor: SURFACE,
              "&:hover": { bgcolor: "rgba(255,255,255,0.07)", borderColor: "rgba(255,255,255,0.12)", color: TEXT },
              transition: "all 0.2s",
            },
            "& .Mui-selected": {
              background: `linear-gradient(135deg,${GOLD},${GOLD_DIM}) !important`,
              color: "#fff !important",
              border: "none !important",
              boxShadow: "0 4px 14px rgba(201,168,76,0.3)",
            },
          }}
        />
      </Box>

      {openAdd && (
        <AddBookPage
          onClose={() => {
            setOpenAdd(false);
            dispatch(fetchBooks(currentPage));
          }}
        />
      )}

      <Dialog
        open={Boolean(editBook)}
        onClose={() => setEditBook(null)}
        PaperProps={{
          sx: {
            borderRadius: "18px", p: 1, minWidth: "360px",
            bgcolor: "#1a1a24",
            border: "1px solid rgba(201,168,76,0.15)",
            boxShadow: "0 24px 60px rgba(0,0,0,0.5)",
          },
        }}
      >
        <DialogTitle sx={{ fontWeight: 700, fontSize: 15, color: TEXT, pb: 0.5 }}>
          Edit book details
        </DialogTitle>

        <DialogContent sx={{ display: "flex", flexDirection: "column", gap: 2, mt: 1.5 }}>
          {[
            { label: "Book Title",              key: "title",      type: "text"   },
            { label: "Price — سعر التكلفة",     key: "price",      type: "number" },
            { label: "Sale Price — سعر المبيع", key: "sale_price", type: "number" },
          ].map(({ label, key, type }) => (
            <TextField
              key={key}
              label={label}
              type={type}
              fullWidth
              size="small"
              value={editForm[key]}
              onChange={(e) => setEditForm({ ...editForm, [key]: e.target.value })}
              sx={{
                "& .MuiOutlinedInput-root": {
                  borderRadius: "10px", fontSize: 13.5, color: TEXT,
                  bgcolor: "rgba(255,255,255,0.04)",
                  "& fieldset": { borderColor: BORDER },
                  "&:hover fieldset": { borderColor: "rgba(255,255,255,0.12)" },
                  "&.Mui-focused fieldset": { borderColor: `${GOLD}60` },
                },
                "& .MuiInputLabel-root": { fontSize: 13.5, color: MUTED },
                "& .MuiInputLabel-root.Mui-focused": { color: GOLD },
                "& input": { color: TEXT },
              }}
            />
          ))}
        </DialogContent>

        <DialogActions sx={{ px: 3, pb: 2.5, gap: 1 }}>
          <Button
            onClick={() => setEditBook(null)}
            sx={{
              borderRadius: "10px", textTransform: "none", fontWeight: 600,
              fontSize: 13.5, color: MUTED,
              border: `1px solid ${BORDER}`, px: 2.5,
              "&:hover": { bgcolor: "rgba(255,255,255,0.05)", color: TEXT },
            }}
          >
            Cancel
          </Button>
          <Button
            onClick={handleSaveEdit}
            variant="contained"
            disableElevation
            sx={{
              borderRadius: "10px", textTransform: "none",
              fontWeight: 700, fontSize: 13.5, px: 3,
              color: "#fff",
              background: `linear-gradient(135deg,${GOLD},${GOLD_DIM})`,
              "&:hover": {
                background: "linear-gradient(135deg,#d4b562,#9e6c20)",
                transform: "translateY(-1px)",
                boxShadow: "0 12px 28px rgba(201,168,76,0.25)",
              },
              transition: "all 0.25s",
            }}
          >
            Save changes
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}