import { createSlice } from "@reduxjs/toolkit";
import {
  fetchBooks,
  createBooks,
  deletBooks,
  updateBooks,
  getBook,
  getBooksWithDetails,
} from "../Thunks/BookThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

const bookSlice = createSlice({
  name: "book",
  initialState: {
    books: [],
    error: null,
    loading: false,
  },
  extraReducers: (builder) => {
    addAsyncCases(builder, fetchBooks, { dataKey: "books" });
    addAsyncCases(builder, createBooks);
    addAsyncCases(builder, deletBooks);
    addAsyncCases(builder, updateBooks);
    addAsyncCases(builder, getBook);
    addAsyncCases(builder, getBooksWithDetails);
  },
});

export default bookSlice.reducer;
