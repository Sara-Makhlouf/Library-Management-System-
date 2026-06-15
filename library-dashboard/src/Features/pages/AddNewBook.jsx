import { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { createBooks } from "../../Core/Redux/Thunks/BookThunk";
import {
  getCategory,
  createCategory,
} from "../../Core/Redux/Thunks/CategoriesThunk";

import {
  getauthor,
  createauthor,
} from "../../Core/Redux/Thunks/AuthorThunk";

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
  Grid,
  Autocomplete,
  createFilterOptions,
  Chip,
  CircularProgress
} from "@mui/material";

import CloseIcon from "@mui/icons-material/Close";
import MenuBookIcon from "@mui/icons-material/MenuBook";
import BadgeIcon from "@mui/icons-material/Badge";
import AttachMoneyIcon from "@mui/icons-material/AttachMoney";
import InventoryIcon from "@mui/icons-material/Inventory";
import CloudUploadIcon from "@mui/icons-material/CloudUpload";
import AutoStoriesIcon from "@mui/icons-material/AutoStories";
import PictureAsPdfIcon from "@mui/icons-material/PictureAsPdf";
import ImageIcon from "@mui/icons-material/Image";
import CategoryIcon from "@mui/icons-material/Category";
import PersonOutlineIcon from "@mui/icons-material/PersonOutline";

const filter = createFilterOptions();

export default function AddBookPage({ onClose }) {
  const dispatch = useDispatch();
  const [loading, setLoading] = useState(false);
  
  const [coverFile, setCoverFile] = useState(null);
  const [coverPreview, setCoverPreview] = useState("");
  const [bookFile, setBookFile] = useState(null);
const navigate = useNavigate();
  const categoriesData = useSelector((state) => state.categories?.categories);
  const categories = Array.isArray(categoriesData) ? categoriesData : (categoriesData?.data ?? []);

  const authorsData = useSelector((state) => state.authors?.authors);
  const authors = Array.isArray(authorsData) ? authorsData : (authorsData?.data ?? []);

  const [selectedCategories, setSelectedCategories] = useState([]);
  const [selectedAuthors, setSelectedAuthors] = useState([]);

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

}else{
  console.log( formData.error);
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

  return (
    <Box
      sx={{
        position: "fixed",
        top: 0,
        left: 0,
        width: "100vw",
        height: "100vh",
backgroundColor: "#111118",        backdropFilter: "blur(20px)",
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
            color: "#423019",
            borderRadius: "16px",
            boxShadow: "0 20px 40px rgba(0,0,0,0.15)",
            fontWeight: 600,
            border: "1px solid rgba(189, 170, 127, 0.3)"
          }
        }} 
      />

      <Card
        component={motion.div}
        initial={{ opacity: 0, scale: 0.92, y: 40 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.92, y: 40 }}
        transition={{ type: "spring", damping: 22, stiffness: 150 }}
        sx={{
          width: "100%",
          maxWidth: "840px",
          maxHeight: "90vh",
          overflowY: "auto",
          borderRadius: "32px",
          background: "linear-gradient(145deg, rgba(255,255,255,0.98) 0%, rgba(253,251,247,0.98) 100%)",
          boxShadow: "0 40px 90px rgba(27, 18, 9, 0.25)",
          border: "1px solid rgba(255, 255, 255, 0.6)",
          p: { xs: 3, md: 5 },
          "&::-webkit-scrollbar": { width: "6px" },
          "&::-webkit-scrollbar-thumb": { backgroundColor: "rgba(92, 67, 34, 0.15)", borderRadius: "10px" }
        }}
      >
        <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", mb: 4.5 }}>
          <Box sx={{ display: "flex", alignItems: "center", gap: 2.5 }}>
            <Box 
              sx={{ 
                background: "linear-gradient(135deg, #ccb78d 0%, #5c4322 100%)", 
                p: 1.5, 
                borderRadius: "20px", 
                display: "flex",
                boxShadow: "0 8px 20px rgba(92, 67, 34, 0.2)"
              }}
            >
              <MenuBookIcon sx={{ color: "#fff", fontSize: 28 }} />
            </Box>
            <Box>
              <Typography variant="h5" sx={{ fontWeight: 900, color: "#2c1e0f", letterSpacing: "-0.5px", mb: 0.5 }}>
                Add New Book Asset
              </Typography>
              <Typography variant="body2" sx={{ color: "#8a7558", fontWeight: 500 }}>
                Create a digital or physical asset profile within the archive management system.
              </Typography>
            </Box>
          </Box>
         <IconButton
  onClick={() => navigate(-1)}
            sx={{ 
              backgroundColor: "rgba(0,0,0,0.03)", 
              p: 1,
              "&:hover": { backgroundColor: "rgba(211, 47, 47, 0.08)", color: "#d32f2f", transform: "rotate(90deg)" },
              transition: "all 0.3s ease"
            }}
          >
            <CloseIcon fontSize="small" />
          </IconButton>
        </Box>

        <form onSubmit={handleSubmit}>
          <Grid container spacing={3}>
            
            <Grid item xs={12} sm={8}>
              <TextField
                fullWidth
                label="Book Title"
                name="title"
                value={book.title}
                onChange={handleChange}
                required
                InputProps={{
                  startAdornment: <InputAdornment position="start"><MenuBookIcon sx={{ fontSize: 20, color: "#ccb78d" }} /></InputAdornment>,
                }}
                sx={{ "& .MuiOutlinedInput-root": { borderRadius: "16px", backgroundColor: "#faf8f5" } }}
              />
            </Grid>

            <Grid item xs={12} sm={4}>
              <TextField
                fullWidth
                label="ISBN Number"
                name="ISBN"
                value={book.ISBN}
                onChange={handleChange}
                required
                InputProps={{
                  startAdornment: <InputAdornment position="start"><BadgeIcon sx={{ fontSize: 20, color: "#ccb78d" }} /></InputAdornment>,
                }}
                sx={{ "& .MuiOutlinedInput-root": { borderRadius: "16px", backgroundColor: "#faf8f5" } }}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <Autocomplete
                multiple
                freeSolo
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
                  tagValue.map((option, index) => (
                    <Chip
                      key={index}
                      label={option.inputValue || option.name}
                      {...getTagProps({ index })}
                      sx={{ borderRadius: "10px", backgroundColor: "rgba(204, 183, 141, 0.2)", color: "#5c4322", fontWeight: 700 }}
                    />
                  ))
                }
                renderInput={(params) => (
                  <TextField 
                    {...params} 
                    label="Genre Categories" 
                    placeholder={selectedCategories.length === 0 ? "Select or Type..." : ""}
                    InputProps={{
                      ...params.InputProps,
                      startAdornment: (
                        <>
                          <InputAdornment position="start"><CategoryIcon sx={{ fontSize: 20, color: "#ccb78d" }} /></InputAdornment>
                          {params.InputProps.startAdornment}
                        </>
                      ),
                    }}
                    sx={{ "& .MuiOutlinedInput-root": { borderRadius: "16px", backgroundColor: "#faf8f5" } }} 
                  />
                )}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <Autocomplete
                multiple
                freeSolo
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
                  tagValue.map((option, index) => (
                    <Chip
                      key={index}
                      label={option.inputValue || option.name}
                      {...getTagProps({ index })}
                      sx={{ borderRadius: "10px", backgroundColor: "rgba(92, 67, 34, 0.12)", color: "#423019", fontWeight: 700 }}
                    />
                  ))
                }
                renderInput={(params) => (
                  <TextField 
                    {...params} 
                    label="Authors" 
                    placeholder={selectedAuthors.length === 0 ? "Select or Type..." : ""}
                    InputProps={{
                      ...params.InputProps,
                      startAdornment: (
                        <>
                          <InputAdornment position="start"><PersonOutlineIcon sx={{ fontSize: 20, color: "#ccb78d" }} /></InputAdornment>
                          {params.InputProps.startAdornment}
                        </>
                      ),
                    }}
                    sx={{ "& .MuiOutlinedInput-root": { borderRadius: "16px", backgroundColor: "#faf8f5" } }} 
                  />
                )}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                type="number"
                label="Cost Price"
                name="price"
                value={book.price}
                onChange={handleChange}
                required
                InputProps={{
                  startAdornment: <InputAdornment position="start"><AttachMoneyIcon sx={{ fontSize: 20, color: "#2e7d32" }} /></InputAdornment>,
                }}
                sx={{ "& .MuiOutlinedInput-root": { borderRadius: "16px", backgroundColor: "#faf8f5" } }}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                type="number"
                label="Rental / Sale Price"
                name="sale_price"
                value={book.sale_price}
                onChange={handleChange}
                required
                InputProps={{
                  startAdornment: <InputAdornment position="start"><AttachMoneyIcon sx={{ fontSize: 20, color: "#2e7d32" }} /></InputAdornment>,
                }}
                sx={{ "& .MuiOutlinedInput-root": { borderRadius: "16px", backgroundColor: "#faf8f5" } }}
              />
            </Grid>

            <Grid item xs={6} sm={4}>
              <TextField
                fullWidth
                type="number"
                label="Available Stock"
                name="stock"
                value={book.stock}
                onChange={handleChange}
                required
                InputProps={{
                  startAdornment: <InputAdornment position="start"><InventoryIcon sx={{ fontSize: 20, color: "#ccb78d" }} /></InputAdornment>,
                }}
                sx={{ "& .MuiOutlinedInput-root": { borderRadius: "16px", backgroundColor: "#faf8f5" } }}
              />
            </Grid>

            <Grid item xs={6} sm={4}>
              <TextField
                fullWidth
                type="number"
                label="Total Copies"
                name="total_copies"
                value={book.total_copies}
                onChange={handleChange}
                required
                sx={{ "& .MuiOutlinedInput-root": { borderRadius: "16px", backgroundColor: "#faf8f5" } }}
              />
            </Grid>

            <Grid item xs={12} sm={4}>
              <TextField
                fullWidth
                type="number"
                label="Total Pages"
                name="total_pages"
                value={book.total_pages}
                onChange={handleChange}
                required
                InputProps={{
                  startAdornment: <InputAdornment position="start"><AutoStoriesIcon sx={{ fontSize: 18, color: "#ccb78d" }} /></InputAdornment>,
                }}
                sx={{ "& .MuiOutlinedInput-root": { borderRadius: "16px", backgroundColor: "#faf8f5" } }}
              />
            </Grid>

         
            <Grid item xs={12} sm={6}>
              <Typography variant="body2" sx={{ fontWeight: 800, color: "#423019", mb: 1.2, display: "flex", alignItems: "center", gap: 0.5 }}>
                <ImageIcon sx={{ fontSize: 18, color: "#ccb78d" }} /> Book Cover Image
              </Typography>
              <Box
                sx={{
                  border: "2px dashed rgba(204, 183, 141, 0.5)",
                  borderRadius: "20px",
                  p: 2.5,
                  height: "140px",
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  justifyContent: "center",
                  backgroundColor: "rgba(253, 251, 247, 0.7)",
                  cursor: "pointer",
                  boxShadow: "inset 0 2px 8px rgba(0,0,0,0.02)",
                  transition: "all 0.25s ease-in-out",
                  "&:hover": { backgroundColor: "rgba(204, 183, 141, 0.08)", borderColor: "#5c4322", transform: "translateY(-2px)" },
                }}
                component="label"
              >
                <input type="file" accept="image/*" hidden onChange={handleCoverChange} />
                {coverPreview ? (
                  <Box sx={{ display: "flex", alignItems: "center", gap: 2.5 }}>
                    <Box
                      component="img"
                      src={coverPreview}
                      sx={{ width: 55, height: 75, objectFit: "cover", borderRadius: "10px", boxShadow: "0 8px 20px rgba(0,0,0,0.15)" }}
                    />
                    <Box>
                      <Typography variant="subtitle2" sx={{ fontWeight: 800, color: "#2e7d32", mb: 0.5 }}>
                        Cover Loaded Perfectly ✨
                      </Typography>
                      <Typography variant="caption" sx={{ color: "#7a664d", display: "block" }}>
                        Click anywhere here to change
                      </Typography>
                    </Box>
                  </Box>
                ) : (
                  <>
                    <CloudUploadIcon sx={{ fontSize: 36, color: "#ccb78d", mb: 1 }} />
                    <Typography variant="body2" sx={{ fontWeight: 700, color: "#5c4322" }}>
                      Drop artwork or browse
                    </Typography>
                  </>
                )}
              </Box>
            </Grid>

            <Grid item xs={12} sm={6}>
              <Typography variant="body2" sx={{ fontWeight: 800, color: "#423019", mb: 1.2, display: "flex", alignItems: "center", gap: 0.5 }}>
                <PictureAsPdfIcon sx={{ fontSize: 18, color: "#ccb78d" }} /> Digital Book File
              </Typography>
              <Box
                sx={{
                  border: "2px dashed rgba(204, 183, 141, 0.5)",
                  borderRadius: "20px",
                  p: 2.5,
                  height: "140px",
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  justifyContent: "center",
                  backgroundColor: "rgba(253, 251, 247, 0.7)",
                  cursor: "pointer",
                  boxShadow: "inset 0 2px 8px rgba(0,0,0,0.02)",
                  transition: "all 0.25s ease-in-out",
                  "&:hover": { backgroundColor: "rgba(204, 183, 141, 0.08)", borderColor: "#5c4322", transform: "translateY(-2px)" },
                }}
                component="label"
              >
                <input type="file" accept=".pdf,.epub,.docx" hidden onChange={handleBookFileChange} />
                {bookFile ? (
                  <Box sx={{ display: "flex", alignItems: "center", gap: 2 }}>
                    <Box sx={{ backgroundColor: "rgba(211, 47, 47, 0.08)", p: 1.5, borderRadius: "14px", display: "flex" }}>
                      <PictureAsPdfIcon sx={{ fontSize: 30, color: "#d32f2f" }} />
                    </Box>
                    <Box sx={{ overflow: "hidden" }}>
                      <Typography variant="subtitle2" sx={{ fontWeight: 800, color: "#2e7d32" }}>
                        E-Book Asset Attached
                      </Typography>
                      <Typography variant="caption" sx={{ color: "#7a664d", display: "block", maxWidth: "200px" }} noWrap>
                        {bookFile.name}
                      </Typography>
                    </Box>
                  </Box>
                ) : (
                  <>
                    <CloudUploadIcon sx={{ fontSize: 36, color: "#ccb78d", mb: 1 }} />
                    <Typography variant="body2" sx={{ fontWeight: 700, color: "#5c4322" }}>
                      Upload PDF, EPUB or DOCX
                    </Typography>
                  </>
                )}
              </Box>
            </Grid>

          </Grid>

          <Box sx={{ display: "flex", justifyContent: "flex-end", gap: 2, mt: 5, pt: 3, borderTop: "1px solid rgba(92, 67, 34, 0.08)" }}>
            <Button
              variant="outlined"
              onClick={onClose}
              disabled={loading}
              sx={{
                borderRadius: "16px",
                px: 4.5,
                py: 1.2,
                textTransform: "none",
                fontWeight: 800,
                color: "#5c4322",
                borderColor: "rgba(204, 183, 141, 0.7)",
                "&:hover": { borderColor: "#5c4322", backgroundColor: "rgba(92, 67, 34, 0.05)" },
              }}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              variant="contained"
              disableElevation
              disabled={loading}
              sx={{
                borderRadius: "16px",
                px: 4.5,
                py: 1.2,
                background: "linear-gradient(135deg, #ccb78d 0%, #5c4322 100%)",
                boxShadow: "0 10px 25px rgba(92, 67, 34, 0.25)",
                textTransform: "none",
                fontWeight: 800,
                gap: 1.5,
                "&:hover": { background: "linear-gradient(135deg, #bfa97e 0%, #473319 100%)", boxShadow: "0 12px 30px rgba(92, 67, 34, 0.35)" },
              }}
            >
              {loading ? <CircularProgress size={20} color="inherit" /> : null}
              {loading ? "Archiving..." : "Save Book Asset"}
            </Button>
          </Box>
        </form>
      </Card>
    </Box>
  );
}