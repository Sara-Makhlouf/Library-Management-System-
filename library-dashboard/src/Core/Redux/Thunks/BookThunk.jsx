import api from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const fetchBooks = createApiThunk("books/fetchBooks", async () => {
  const response = await api.get("/books");
  return response.data;
});

export const createBooks = createApiThunk(
  "books/createBooks",
  async (bookData) => {
    const response = await api.post("/books", bookData);
    return response.data;
  }
);

export const deletBooks = createApiThunk(
  "books/deleteBooks",
  async (bookId) => {
    const response = await api.delete("/books/" + bookId);
    return response.data;
  }
);

export const updateBooks = createApiThunk(
  "books/updateBooks",
  async (bookData, bookId) => {
    const response = await api.put("/books/" + bookId, bookData);
    return response.data;
  }
);

export const getBook = createApiThunk(
  "books/getBookById",
  async (bookId) => {
    const response = await api.get("/books/" + bookId);
    return response.data;
  }
);

export const getBooksWithDetails = createApiThunk(
  "books/getBooksWithDetails",
  async (bookId) => {
    const response = await api.get("/books/" + bookId);
    return response.data;
  }
);
