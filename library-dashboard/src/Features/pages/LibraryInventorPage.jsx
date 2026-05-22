import {
  Box,
  Typography,
  TextField,
  Select,
  MenuItem,
  Button,
  Card,
  Avatar,
  Chip,
} from "@mui/material";

import { useEffect, useState } from "react";
import { useBooks } from "../../Core/Context/BooksContext";

export default function LibraryInventoryPage() {
  const { books, getBooks, loading } = useBooks();

  const [search, setSearch] = useState("");
  const [genre, setGenre] = useState("");
  const [status, setStatus] = useState("");

  useEffect(() => {
    getBooks();
  }, [getBooks]);

  const filteredBooks = books?.filter((book) => {
    return (
      book.title?.toLowerCase().includes(search.toLowerCase()) &&
      (genre ? book.genre === genre : true) &&
      (status ? book.status === status : true)
    );
  });

  if (loading) {
    return (
      <Box sx={{ p: 4 }}>
        <Typography>Loading books...</Typography>
      </Box>
    );
  }

  return (
    <Box
      sx={{
        p: 4,
        minHeight: "100vh",
        background: "linear-gradient(135deg,#f8f6ef,#f1eee6)",
      }}
    >
      <Box sx={{ mb: 3 }}>
        <Typography sx={{ fontSize: "1.8rem", fontWeight: 700 }}>
          Library Inventory 📚
        </Typography>

        <Typography sx={{ opacity: 0.6 }}>
          Manage books, authors and availability
        </Typography>
      </Box>

      <Card
        sx={{
          p: 2,
          mb: 3,
          borderRadius: "16px",
          boxShadow: "0 8px 20px rgba(0,0,0,0.06)",
        }}
      >
        <Box sx={{ display: "flex", gap: 2, flexWrap: "wrap" }}>
          <TextField
            placeholder="Search..."
            size="small"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            sx={{ flex: 1 }}
          />

          <Select
            size="small"
            value={genre}
            onChange={(e) => setGenre(e.target.value)}
            displayEmpty
          >
            <MenuItem value="">All Genres</MenuItem>
            <MenuItem value="History">History</MenuItem>
            <MenuItem value="Sci-Fi">Sci-Fi</MenuItem>
          </Select>

          <Select
            size="small"
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            displayEmpty
          >
            <MenuItem value="">All Status</MenuItem>
            <MenuItem value="Available">Available</MenuItem>
            <MenuItem value="Borrowed">Borrowed</MenuItem>
          </Select>

          <Button
            variant="contained"
            sx={{
              borderRadius: "10px",
              background: "rgb(189,170,127)",
            }}
          >
            + Add Book
          </Button>
        </Box>
      </Card>

      <Card
        sx={{
          borderRadius: "18px",
          overflow: "hidden",
          boxShadow: "0 12px 30px rgba(0,0,0,0.08)",
        }}
      >
        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: "2fr 1fr 1fr 1fr 1fr",
            p: 2,
            fontWeight: 600,
            background: "#faf9f5",
          }}
        >
          <span>Book</span>
          <span>ISBN</span>
          <span>Genre</span>
          <span>Status</span>
          <span>Price</span>
        </Box>

        {filteredBooks?.length > 0 ? (
          filteredBooks.map((book) => (
            <Box
              key={book.id}
              sx={{
                display: "grid",
                gridTemplateColumns: "2fr 1fr 1fr 1fr 1fr",
                alignItems: "center",
                p: 2,
                borderTop: "1px solid #eee",
                transition: "0.2s",
                "&:hover": {
                  background: "#fafafa",
                },
              }}
            >
              <Box sx={{ display: "flex", alignItems: "center", gap: 2 }}>
                <Avatar src={book.cover} variant="rounded" />
                <Box>
                  <Typography sx={{ fontWeight: 600 }}>
                    {book.title}
                  </Typography>
                  <Typography sx={{ fontSize: "0.75rem", opacity: 0.6 }}>
                    {book.author}
                  </Typography>
                </Box>
              </Box>

              <Typography>{book.isbn}</Typography>
              <Typography>{book.genre}</Typography>

              <Chip
                label={book.status}
                size="small"
                sx={{
                  bgcolor:
                    book.status === "Available"
                      ? "#e8f5e9"
                      : "#fff3e0",
                }}
              />

              <Typography sx={{ fontWeight: 500 }}>
                {book.price}
              </Typography>
            </Box>
          ))
        ) : (
          <Box sx={{ p: 3 }}>
            <Typography>No books found</Typography>
          </Box>
        )}
      </Card>
    </Box>
  );
}