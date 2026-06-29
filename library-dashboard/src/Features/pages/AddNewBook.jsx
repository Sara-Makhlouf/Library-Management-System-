import { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { createBooks } from "../../Core/Redux/Thunks/BookThunk";
import {
  getCategory, createCategory,updateCategory,deleteCategory} from "../../Core/Redux/Thunks/CategoriesThunk";

import {
  getauthor,createauthor,updateAuthor,deleteAuthor} from "../../Core/Redux/Thunks/AuthorThunk";

import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import toast, { Toaster } from "react-hot-toast";

import {
  Box,
  Typography,
  TextField,
  Button,
  Card,
  IconButton,
  InputAdornment,
  Autocomplete,
  createFilterOptions,
  Chip,
  CircularProgress,
} from "@mui/material";

import CloseIcon from "@mui/icons-material/Close";
import BadgeIcon from "@mui/icons-material/Badge";
import InventoryIcon from "@mui/icons-material/Inventory";
import CloudUploadIcon from "@mui/icons-material/CloudUpload";
import AutoStoriesIcon from "@mui/icons-material/AutoStories";
import PictureAsPdfIcon from "@mui/icons-material/PictureAsPdf";
import CategoryIcon from "@mui/icons-material/Category";
import PersonOutlineIcon from "@mui/icons-material/PersonOutline";
import CheckCircleIcon from "@mui/icons-material/CheckCircle";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import CheckIcon from "@mui/icons-material/Check";

const filter = createFilterOptions();

const FONT_IMPORT_ID = "lib-fonts";
const FONT_HREF =
  "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,300..700,0..100,0..1&family=Inter:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@500;600&display=swap";

function injectFonts() {
  if (document.getElementById(FONT_IMPORT_ID)) return;
  const link = document.createElement("link");
  link.id = FONT_IMPORT_ID;
  link.rel = "stylesheet";
  link.href = FONT_HREF;
  document.head.appendChild(link);
}

const display = { fontFamily: "'Fraunces', serif" };
const mono = { fontFamily: "'IBM Plex Mono', monospace" };

const INK      = "#2c1e0f";
const INK_SOFT = "#7a664d";
const PAPER    = "#fdfbf7";
const PARCHMENT = "#f3ecdf";
const CLOTH    = "#8b6b3d";
const CLOTH_DEEP = "#3d2c14";

const fieldSx = {
  "& .MuiOutlinedInput-root": {
    borderRadius: "12px",
    backgroundColor: PAPER,
    fontSize: 14,
  },
};


function SectionLabel({ index, children }) {
  return (
    <Box sx={{ display: "flex", alignItems: "center", gap: 1.1, mb: 1.8 }}>
      <Box
        sx={{
          ...mono,
          width: 22, height: 22, borderRadius: "7px",
          bgcolor: CLOTH_DEEP, color: PARCHMENT,
          fontSize: 11, fontWeight: 600,
          display: "flex", alignItems: "center", justifyContent: "center",
          flexShrink: 0,
        }}
      >
        {index}
      </Box>
      <Typography sx={{ fontSize: 11.5, fontWeight: 700, color: INK, letterSpacing: ".6px", textTransform: "uppercase" }}>
        {children}
      </Typography>
    </Box>
  );
}


function EditableChip({
  option,
  label,
  onConfirmEdit,
  onDelete,
  onRemove,
  busy,
  accentBg,
  accentColor,
}) {
  const [editing, setEditing] = useState(false);
  const [value, setValue] = useState(label);

  const canManage = Boolean(option?.id); 
  const isBusy = busy === option?.id;

  if (editing) {
    return (
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          gap: 0.5,
          bgcolor: PAPER,
          border: `1px solid ${CLOTH}`,
          borderRadius: "8px",
          px: 0.75,
          py: 0.25,
          m: "2px",
        }}
      >
        <TextField
          autoFocus
          size="small"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          onKeyDown={(e) => {
       
            e.stopPropagation();

            if (e.key === "Enter") {
              e.preventDefault();
              if (value.trim() && value.trim() !== label) {
                onConfirmEdit(option, value.trim());
              }
              setEditing(false);
            }
            if (e.key === "Escape") {
              setValue(label);
              setEditing(false);
            }
          }}
          variant="standard"
          InputProps={{ disableUnderline: true, sx: { fontSize: 12, fontWeight: 700, color: CLOTH_DEEP, width: Math.max(60, value.length * 7) } }}
        />
        <IconButton
          size="small"
          onClick={() => {
            if (value.trim() && value.trim() !== label) {
              onConfirmEdit(option, value.trim());
            }
            setEditing(false);
          }}
          sx={{ p: 0.25 }}
        >
          <CheckIcon sx={{ fontSize: 14, color: "#2e7d32" }} />
        </IconButton>
        <IconButton
          size="small"
          onClick={() => {
            setValue(label);
            setEditing(false);
          }}
          sx={{ p: 0.25 }}
        >
          <CloseIcon sx={{ fontSize: 14, color: INK_SOFT }} />
        </IconButton>
      </Box>
    );
  }

  return (
    <Chip
      label={
        <Box sx={{ display: "flex", alignItems: "center", gap: 0.5 }}>
          <span>{label}</span>
          {canManage && (
            <>
              {isBusy ? (
                <CircularProgress size={11} sx={{ color: accentColor, ml: 0.25 }} />
              ) : (
                <>
                  <EditIcon
                    sx={{ fontSize: 13, color: accentColor, opacity: 0.7, cursor: "pointer", "&:hover": { opacity: 1 } }}
                    onMouseDown={(e) => e.stopPropagation()}
                    onClick={(e) => {
                      e.stopPropagation();
                      setValue(label);
                      setEditing(true);
                    }}
                  />
                  <DeleteIcon
                    sx={{ fontSize: 13, color: "#c0392b", opacity: 0.7, cursor: "pointer", "&:hover": { opacity: 1 } }}
                    onMouseDown={(e) => e.stopPropagation()}
                    onClick={(e) => {
                      e.stopPropagation();
                      onDelete(option);
                    }}
                  />
                </>
              )}
            </>
          )}
        </Box>
      }
      onDelete={onRemove}
      sx={{
        borderRadius: "8px",
        bgcolor: accentBg,
        color: accentColor,
        fontWeight: 700,
        fontSize: 12,
        "& .MuiChip-label": { display: "flex", alignItems: "center" },
      }}
    />
  );
}

export default function AddBookPage({ onClose }) {
  const dispatch = useDispatch();
  const [loading, setLoading] = useState(false);

  const [coverFile, setCoverFile] = useState(null);
  const [coverPreview, setCoverPreview] = useState("");
  const [bookFile, setBookFile] = useState(null);
  const navigate = useNavigate();

  useEffect(() => { injectFonts(); }, []);

  const categoriesData = useSelector((state) => state.categories?.categories);
  const categories = Array.isArray(categoriesData) ? categoriesData : (categoriesData?.data ?? []);

  const authorsData = useSelector((state) => state.authors?.authors);
  const authors = Array.isArray(authorsData) ? authorsData : (authorsData?.data ?? []);

  const [selectedCategories, setSelectedCategories] = useState([]);
  const [selectedAuthors, setSelectedAuthors] = useState([]);

  const [busyCategoryId, setBusyCategoryId] = useState(null);
  const [busyAuthorId, setBusyAuthorId] = useState(null);

  const [book, setBook] = useState({
    title: "",
    ISBN: "",
    price: "",
    sale_price: "",
    stock: "",
    total_copies: "",
    borrow_duration: "7",
    is_digital: "0",
    total_pages: "",
  });

  useEffect(() => {
    if (dispatch) {
      dispatch(getCategory?.());
      dispatch(getauthor?.());
    }
  }, [dispatch]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setBook((prev) => ({ ...prev, [name]: value }));
  };

  const handleCoverChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setCoverFile(file);
      setCoverPreview(URL.createObjectURL(file));
    }
  };

  const handleBookFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setBookFile(file);
      setBook((prev) => ({ ...prev, is_digital: "1" }));
    }
  };

  const handleEditCategory = async (option, newName) => {
    if (!option?.id) return;
    setBusyCategoryId(option.id);
    try {
    
      const updated = await dispatch(
        updateCategory({ id: option.id, categoryData: { name: newName } })
      ).unwrap();

      const updatedCategory = updated?.data || updated;

      setSelectedCategories((prev) =>
        prev.map((c) => (c.id === option.id ? { ...c, name: updatedCategory?.name || newName } : c))
      );

      toast.success("The Cateogry edit successful   ");
    } catch (error) {
      toast.error(error?.message || "cant edit this category");
    } finally {
      setBusyCategoryId(null);
    }
  };

  const handleDeleteCategory = async (option) => {
    if (!option?.id) return;
    setBusyCategoryId(option.id);
    try {
      await dispatch(deleteCategory(option.id)).unwrap();

      setSelectedCategories((prev) => prev.filter((c) => c.id !== option.id));

      toast.success("the category  deleted");
    } catch (error) {
      toast.error(error?.message || "  cant delete this category");
    } finally {
      setBusyCategoryId(null);
    }
  };

  const handleEditAuthor = async (option, newName) => {
    if (!option?.id) return;
    setBusyAuthorId(option.id);
    try {
     
      const updated = await dispatch(
        updateAuthor({ id: option.id, authorData: { name: newName } })
      ).unwrap();

      const updatedAuthor = updated?.data || updated;

      setSelectedAuthors((prev) =>
        prev.map((a) => (a.id === option.id ? { ...a, name: updatedAuthor?.name || newName } : a))
      );

      toast.success(" The author edit successfully ");
    } catch (error) {
      toast.error(error?.message || " cant edit the author ");
    } finally {
      setBusyAuthorId(null);
    }
  };

  const handleDeleteAuthor = async (option) => {
    if (!option?.id) return;
    setBusyAuthorId(option.id);
    try {
      await dispatch(deleteAuthor(option.id)).unwrap();

      setSelectedAuthors((prev) => prev.filter((a) => a.id !== option.id));

      toast.success("author is deleted   ");
    } catch (error) {
      toast.error(error?.message || " cant delete author ");
    } finally {
      setBusyAuthorId(null);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (selectedCategories.length === 0 || selectedAuthors.length === 0) {
      toast.error("Please Select a one categories at least");
      return;
    }

    setLoading(true);

    try {
      const categoryIds = [];
      const authorIds = [];

      for (const category of selectedCategories) {
        if (category.id) {
          categoryIds.push(category.id);
          continue;
        }

        const categoryName =
          category.inputValue?.trim() || category.name?.trim();

        const existingCategory = categories.find(
          (c) =>
            c.name.trim().toLowerCase() ===
            categoryName.toLowerCase()
        );

        if (existingCategory) {
          categoryIds.push(existingCategory.id);
        } else {
          const createdCategory = await dispatch(
            createCategory({
              name: categoryName,
            })
          ).unwrap();

          categoryIds.push(createdCategory.data.id);
        }
      }

      for (const author of selectedAuthors) {
        if (author.id) {
          authorIds.push(author.id);
          continue;
        }

        const authorName =
          author.inputValue?.trim() || author.name?.trim();

        const existingAuthor = authors.find(
          (a) =>
            a.name.trim().toLowerCase() ===
            authorName.toLowerCase()
        );

        if (existingAuthor) {
          authorIds.push(existingAuthor.id);
        } else {
          const createdAuthor = await dispatch(
            createauthor({
              name: authorName,
            })
          ).unwrap();

          authorIds.push(createdAuthor.data.id);
        }
      }

      const formData = new FormData();

      formData.append("title", book.title);
      formData.append("ISBN", book.ISBN);
      formData.append("price", book.price);
      formData.append("sale_price", book.sale_price);
      formData.append("stock", book.stock);
      formData.append("total_copies", book.total_copies);
      formData.append("borrow_duration", book.borrow_duration);
      formData.append("is_digital", book.is_digital);
      formData.append("total_pages", book.total_pages);
      formData.append("cover", coverFile);
      formData.append("category_id", categoryIds[0]);

      authorIds.forEach((id) => {
        formData.append("authors[]", id);
      });

      if (bookFile) {
        formData.append("file_path", bookFile);
      } else {
        console.log(formData.error);
      }

      await dispatch(createBooks(formData)).unwrap();
      for (let pair of formData.entries()) {
        console.log(pair[0], pair[1]);
      }
      toast.success("Book Added Successfully");

      navigate("/inventory");
    } catch (error) {
      console.error(error);

      toast.error(
        error?.message || "Error to save data"
      );
    } finally {
      setLoading(false);
    }
  };

  const authorNames = selectedAuthors.map((a) => a.inputValue || a.name).filter(Boolean).join(", ");

  return (
    <Box
      sx={{
        position: "fixed",
        top: 0, left: 0,
        width: "100vw", height: "100vh",
        backgroundColor: "rgba(17,17,24,0.4)",
        backdropFilter: "blur(10px)",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        zIndex: 1300,
        p: 2,
      }}
    >
      <Toaster
        toastOptions={{
          style: {
            background: "rgba(255, 255, 255, 0.95)",
            backdropFilter: "blur(10px)",
            color: INK_SOFT,
            borderRadius: "16px",
            boxShadow: "0 20px 40px rgba(0,0,0,0.15)",
            fontWeight: 600,
            border: `1px solid ${CLOTH}4d`,
          },
        }}
      />

      <Card
        component={motion.div}
        initial={{ opacity: 0, scale: 0.95, y: 24 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 24 }}
        transition={{ type: "spring", damping: 24, stiffness: 220 }}
        sx={{
          width: "100%",
          maxWidth: "980px",
          maxHeight: "92vh",
          borderRadius: "28px",
          background: PAPER,
          boxShadow: "0 40px 90px rgba(27, 18, 9, 0.3)",
          border: "1px solid rgba(255,255,255,0.6)",
          display: "flex",
          overflow: "hidden",
        }}
      >
        <Box
          sx={{
            width: 280,
            flexShrink: 0,
            display: { xs: "none", md: "flex" },
            flexDirection: "column",
            background: `linear-gradient(165deg, ${CLOTH_DEEP} 0%, #1f160a 100%)`,
            p: "32px 28px",
            position: "relative",
            overflow: "hidden",
          }}
        >
          <Box sx={{ position: "absolute", top: -60, right: -60, width: 200, height: 200, borderRadius: "50%", background: `radial-gradient(circle, ${CLOTH}33 0%, transparent 70%)` }} />

          <Typography sx={{ fontSize: 10, fontWeight: 700, color: `${PARCHMENT}99`, letterSpacing: ".7px", textTransform: "uppercase", mb: 3 }}>
            New Archive Entry
          </Typography>

        
          <Box sx={{ display: "flex", justifyContent: "center", mb: 3.5 }}>
            <Box
              sx={{
                width: 142, height: 198,
                borderRadius: "4px 8px 8px 4px",
                position: "relative",
                boxShadow: "0 18px 40px rgba(0,0,0,0.45), 0 2px 0 rgba(255,255,255,0.06) inset",
                background: coverPreview
                  ? `url(${coverPreview}) center/cover no-repeat`
                  : `linear-gradient(135deg, ${CLOTH} 0%, ${CLOTH_DEEP} 100%)`,
                display: "flex", flexDirection: "column",
                justifyContent: "flex-end",
                overflow: "hidden",
              }}
            >
              <Box sx={{ position: "absolute", left: 0, top: 0, bottom: 0, width: 8, bgcolor: "rgba(0,0,0,0.28)" }} />
              {!coverPreview && (
                <Box sx={{ p: "16px 14px", textAlign: "center" }}>
                  <Typography
                    sx={{
                      ...display,
                      fontSize: book.title.length > 18 ? 13 : 15,
                      fontWeight: 600,
                      color: "#fff",
                      lineHeight: 1.25,
                      wordBreak: "break-word",
                    }}
                  >
                    {book.title || "Untitled book"}
                  </Typography>
                </Box>
              )}
            </Box>
          </Box>

          <Typography sx={{ ...display, fontSize: 15, fontWeight: 600, color: "#fff", textAlign: "center", mb: 0.4, lineHeight: 1.3 }}>
            {book.title || "Working title"}
          </Typography>
          <Typography sx={{ fontSize: 11.5, color: `${PARCHMENT}88`, textAlign: "center", mb: 3 }}>
            {authorNames || "Author pending"}
          </Typography>

       
          <Box sx={{ mt: "auto", display: "flex", flexDirection: "column", gap: 1 }}>
            {[
              { label: "Title & ISBN", done: book.title && book.ISBN },
              { label: "Category & author", done: selectedCategories.length > 0 && selectedAuthors.length > 0 },
              { label: "Pricing & stock", done: book.price && book.sale_price && book.stock },
              { label: "Cover artwork", done: Boolean(coverFile) },
            ].map((item) => (
              <Box key={item.label} sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                <CheckCircleIcon sx={{ fontSize: 14, color: item.done ? "#9fd9a8" : "rgba(255,255,255,0.18)" }} />
                <Typography sx={{ fontSize: 11.5, color: item.done ? "#fff" : "rgba(255,255,255,0.4)", fontWeight: 500 }}>
                  {item.label}
                </Typography>
              </Box>
            ))}
          </Box>
        </Box>

        <Box sx={{ flex: 1, display: "flex", flexDirection: "column", minWidth: 0 }}>
          <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", px: { xs: 3, md: 4.5 }, pt: { xs: 3, md: 4 }, pb: 2 }}>
            <Box>
              <Typography sx={{ ...display, fontSize: 21, fontWeight: 600, color: INK, letterSpacing: -0.3 }}>
                Add a new book
              </Typography>
              <Typography sx={{ fontSize: 12.5, color: INK_SOFT, mt: 0.3 }}>
                Four quick sections — identify, classify, price, attach.
              </Typography>
            </Box>
            <IconButton
              onClick={onClose}
              sx={{
                bgcolor: "rgba(0,0,0,0.03)",
                "&:hover": { bgcolor: "rgba(211,47,47,0.08)", color: "#d32f2f", transform: "rotate(90deg)" },
                transition: "all 0.3s ease",
              }}
            >
              <CloseIcon fontSize="small" />
            </IconButton>
          </Box>

          <Box
            component="form"
            onSubmit={handleSubmit}
            sx={{
              flex: 1, overflowY: "auto",
              px: { xs: 3, md: 4.5 }, pb: 3,
              display: "flex", flexDirection: "column", gap: 3.5,
              "&::-webkit-scrollbar": { width: "6px" },
              "&::-webkit-scrollbar-thumb": { backgroundColor: `${CLOTH_DEEP}26`, borderRadius: "10px" },
            }}
          >
            <Box>
              <SectionLabel index="1">Identify the book</SectionLabel>
              <Box sx={{ display: "flex", gap: 1.5, flexDirection: { xs: "column", sm: "row" } }}>
                <TextField
                  fullWidth
                  label="Book title"
                  name="title"
                  value={book.title}
                  onChange={handleChange}
                  required
                  sx={{ ...fieldSx, flex: 2 }}
                />
                <TextField
                  fullWidth
                  label="ISBN"
                  name="ISBN"
                  value={book.ISBN}
                  onChange={handleChange}
                  required
                  InputProps={{
                    startAdornment: <InputAdornment position="start"><BadgeIcon sx={{ fontSize: 18, color: CLOTH }} /></InputAdornment>,
                  }}
                  sx={{ ...fieldSx, flex: 1 }}
                />
              </Box>
            </Box>

            <Box>
              <SectionLabel index="2">Classify it</SectionLabel>
              <Box sx={{ display: "flex", gap: 1.5, flexDirection: { xs: "column", sm: "row" } }}>
                <Autocomplete
                  multiple
                  freeSolo
                  fullWidth
                  value={selectedCategories}
                  onChange={(event, newValue) => {
                    const processed = newValue.map((item) => {
                      if (typeof item === "string") return { name: item, isNewOption: true, inputValue: item };
                      if (item && item.inputValue) return { name: item.inputValue, isNewOption: true, inputValue: item.inputValue };
                      return item;
                    });
                    setSelectedCategories(processed);
                  }}
                  filterOptions={(options, params) => {
                    const filtered = filter(options, params);
                    const { inputValue } = params;
                    const isExisting = options.some((option) => inputValue.toLowerCase() === option.name?.toLowerCase());
                    if (inputValue !== "" && !isExisting) {
                      filtered.push({ inputValue, name: `+ Create "${inputValue}"`, isNewOption: true });
                    }
                    return filtered;
                  }}
                  options={categories}
                  getOptionLabel={(option) => option.inputValue || option.name || ""}
                  renderTags={(tagValue, getTagProps) =>
                    tagValue.map((option, index) => {
                      const { onDelete } = getTagProps({ index });
                      return (
                        <EditableChip
                          key={option.id ?? index}
                          option={option}
                          label={option.inputValue || option.name}
                          onRemove={onDelete}
                          onConfirmEdit={handleEditCategory}
                          onDelete={handleDeleteCategory}
                          busy={busyCategoryId}
                          accentBg={`${CLOTH}26`}
                          accentColor={CLOTH_DEEP}
                        />
                      );
                    })
                  }
                  renderInput={(params) => (
                    <TextField
                      {...params}
                      label="Genre / category"
                      placeholder={selectedCategories.length === 0 ? "Select or type to create…" : ""}
                      InputProps={{
                        ...params.InputProps,
                        startAdornment: (
                          <>
                            <InputAdornment position="start"><CategoryIcon sx={{ fontSize: 18, color: CLOTH }} /></InputAdornment>
                            {params.InputProps.startAdornment}
                          </>
                        ),
                      }}
                      sx={fieldSx}
                    />
                  )}
                />

                <Autocomplete
                  multiple
                  freeSolo
                  fullWidth
                  value={selectedAuthors}
                  onChange={(event, newValue) => {
                    const processed = newValue.map((item) => {
                      if (typeof item === "string") return { name: item, isNewOption: true, inputValue: item };
                      if (item && item.inputValue) return { name: item.inputValue, isNewOption: true, inputValue: item.inputValue };
                      return item;
                    });
                    setSelectedAuthors(processed);
                  }}
                  filterOptions={(options, params) => {
                    const filtered = filter(options, params);
                    const { inputValue } = params;
                    const isExisting = options.some((option) => inputValue.toLowerCase() === option.name?.toLowerCase());
                    if (inputValue !== "" && !isExisting) {
                      filtered.push({ inputValue, name: `+ Add "${inputValue}"`, isNewOption: true });
                    }
                    return filtered;
                  }}
                  options={authors}
                  getOptionLabel={(option) => option.inputValue || option.name || ""}
                  renderTags={(tagValue, getTagProps) =>
                    tagValue.map((option, index) => {
                      const { onDelete } = getTagProps({ index });
                      return (
                        <EditableChip
                          key={option.id ?? index}
                          option={option}
                          label={option.inputValue || option.name}
                          onRemove={onDelete}
                          onConfirmEdit={handleEditAuthor}
                          onDelete={handleDeleteAuthor}
                          busy={busyAuthorId}
                          accentBg="rgba(61,44,20,0.1)"
                          accentColor={CLOTH_DEEP}
                        />
                      );
                    })
                  }
                  renderInput={(params) => (
                    <TextField
                      {...params}
                      label="Author(s)"
                      placeholder={selectedAuthors.length === 0 ? "Select or type to add…" : ""}
                      InputProps={{
                        ...params.InputProps,
                        startAdornment: (
                          <>
                            <InputAdornment position="start"><PersonOutlineIcon sx={{ fontSize: 18, color: CLOTH }} /></InputAdornment>
                            {params.InputProps.startAdornment}
                          </>
                        ),
                      }}
                      sx={fieldSx}
                    />
                  )}
                />
              </Box>
              <Typography sx={{ fontSize: 10.5, color: INK_SOFT, mt: 0.8 }}>
                Click the pencil on a tag to rename it, or the trash icon to remove it everywhere.
              </Typography>
            </Box>

            <Box>
              <SectionLabel index="3">Set price and stock</SectionLabel>
              <Box
                sx={{
                  display: "grid",
                  gridTemplateColumns: { xs: "1fr 1fr", sm: "repeat(4, 1fr)" },
                  gap: 1.5,
                }}
              >
                <TextField
                  fullWidth
                  type="number"
                  label="Cost price"
                  name="price"
                  value={book.price}
                  onChange={handleChange}
                  required
                  InputProps={{ sx: mono }}
                  sx={fieldSx}
                />
                <TextField
                  fullWidth
                  type="number"
                  label="Sale price"
                  name="sale_price"
                  value={book.sale_price}
                  onChange={handleChange}
                  required
                  InputProps={{ sx: mono }}
                  sx={fieldSx}
                />
                <TextField
                  fullWidth
                  type="number"
                  label="Stock"
                  name="stock"
                  value={book.stock}
                  onChange={handleChange}
                  required
                  InputProps={{
                    sx: mono,
                    startAdornment: <InputAdornment position="start"><InventoryIcon sx={{ fontSize: 17, color: CLOTH }} /></InputAdornment>,
                  }}
                  sx={fieldSx}
                />
                <TextField
                  fullWidth
                  type="number"
                  label="Total copies"
                  name="total_copies"
                  value={book.total_copies}
                  onChange={handleChange}
                  required
                  InputProps={{ sx: mono }}
                  sx={fieldSx}
                />
              </Box>
              <TextField
                fullWidth
                type="number"
                label="Total pages"
                name="total_pages"
                value={book.total_pages}
                onChange={handleChange}
                required
                InputProps={{
                  sx: mono,
                  startAdornment: <InputAdornment position="start"><AutoStoriesIcon sx={{ fontSize: 17, color: CLOTH }} /></InputAdornment>,
                }}
                sx={{ ...fieldSx, mt: 1.5, maxWidth: { sm: "calc(25% - 9px)" } }}
              />
            </Box>

            <Box>
              <SectionLabel index="4">Attach files</SectionLabel>
              <Box sx={{ display: "flex", gap: 1.5, flexDirection: { xs: "column", sm: "row" } }}>
                <Box
                  component="label"
                  sx={{
                    flex: 1,
                    border: `1.5px dashed ${CLOTH}80`,
                    borderRadius: "14px",
                    p: 2,
                    height: 92,
                    display: "flex", alignItems: "center", gap: 1.5,
                    bgcolor: `${PARCHMENT}55`,
                    cursor: "pointer",
                    transition: "all .2s",
                    "&:hover": { bgcolor: `${CLOTH}14`, borderColor: CLOTH_DEEP },
                  }}
                >
                  <input type="file" accept="image/*" hidden onChange={handleCoverChange} />
                  {coverPreview ? (
                    <>
                      <Box component="img" src={coverPreview} sx={{ width: 40, height: 56, objectFit: "cover", borderRadius: "6px", boxShadow: "0 6px 14px rgba(0,0,0,0.18)" }} />
                      <Box>
                        <Typography sx={{ fontSize: 12.5, fontWeight: 700, color: "#2e7d32" }}>Cover attached</Typography>
                        <Typography sx={{ fontSize: 11, color: INK_SOFT }}>Tap to replace</Typography>
                      </Box>
                    </>
                  ) : (
                    <>
                      <CloudUploadIcon sx={{ fontSize: 24, color: CLOTH }} />
                      <Box>
                        <Typography sx={{ fontSize: 12.5, fontWeight: 700, color: INK }}>Cover artwork</Typography>
                        <Typography sx={{ fontSize: 11, color: INK_SOFT }}>JPG or PNG</Typography>
                      </Box>
                    </>
                  )}
                </Box>

                <Box
                  component="label"
                  sx={{
                    flex: 1,
                    border: `1.5px dashed ${CLOTH}80`,
                    borderRadius: "14px",
                    p: 2,
                    height: 92,
                    display: "flex", alignItems: "center", gap: 1.5,
                    bgcolor: `${PARCHMENT}55`,
                    cursor: "pointer",
                    transition: "all .2s",
                    "&:hover": { bgcolor: `${CLOTH}14`, borderColor: CLOTH_DEEP },
                  }}
                >
                  <input type="file" accept=".pdf,.epub,.docx" hidden onChange={handleBookFileChange} />
                  {bookFile ? (
                    <>
                      <Box sx={{ bgcolor: "rgba(211,47,47,0.08)", p: 1, borderRadius: "10px", display: "flex" }}>
                        <PictureAsPdfIcon sx={{ fontSize: 22, color: "#d32f2f" }} />
                      </Box>
                      <Box sx={{ overflow: "hidden" }}>
                        <Typography sx={{ fontSize: 12.5, fontWeight: 700, color: "#2e7d32" }}>Digital file attached</Typography>
                        <Typography sx={{ fontSize: 11, color: INK_SOFT, maxWidth: 150, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                          {bookFile.name}
                        </Typography>
                      </Box>
                    </>
                  ) : (
                    <>
                      <CloudUploadIcon sx={{ fontSize: 24, color: CLOTH }} />
                      <Box>
                        <Typography sx={{ fontSize: 12.5, fontWeight: 700, color: INK }}>Digital edition</Typography>
                        <Typography sx={{ fontSize: 11, color: INK_SOFT }}>PDF, EPUB or DOCX — optional</Typography>
                      </Box>
                    </>
                  )}
                </Box>
              </Box>
            </Box>
          </Box>

          <Box
            sx={{
              display: "flex", justifyContent: "flex-end", gap: 1.5,
              px: { xs: 3, md: 4.5 }, py: 2.5,
              borderTop: `1px solid ${CLOTH_DEEP}14`,
              bgcolor: `${PARCHMENT}40`,
            }}
          >
            <Button
              variant="outlined"
              onClick={onClose}
              disabled={loading}
              sx={{
                borderRadius: "12px", px: 3.5, py: 1.1,
                textTransform: "none", fontWeight: 700,
                color: CLOTH_DEEP, borderColor: `${CLOTH}90`,
                "&:hover": { borderColor: CLOTH_DEEP, bgcolor: `${CLOTH}0d` },
              }}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              onClick={handleSubmit}
              variant="contained"
              disableElevation
              disabled={loading}
              sx={{
                borderRadius: "12px", px: 3.5, py: 1.1,
                background: `linear-gradient(135deg, ${CLOTH} 0%, ${CLOTH_DEEP} 100%)`,
                boxShadow: "0 10px 22px rgba(61,44,20,0.25)",
                textTransform: "none", fontWeight: 700,
                display: "flex", gap: 1.2,
                "&:hover": { background: `linear-gradient(135deg, #9c7a48 0%, #2e2110 100%)`, boxShadow: "0 12px 26px rgba(61,44,20,0.35)" },
              }}
            >
              {loading ? <CircularProgress size={18} color="inherit" /> : null}
              {loading ? "Saving…" : "Save book"}
            </Button>
          </Box>
        </Box>
      </Card>
    </Box>
  );
}