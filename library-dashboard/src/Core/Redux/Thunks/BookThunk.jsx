import {  createAsyncThunk, } from "@reduxjs/toolkit";
import api from "../../Api/aixos";


export const fetchBooks = createAsyncThunk(
  "books/fetchBooks",
  async (page = 1, { rejectWithValue }) => {
    try {
      const response = await api.get(`/books?page=${page}`);
      return response.data.data; 
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const createBooks = createAsyncThunk(
    "books/createBooks",
    async (bookData, { rejectWithValue }) => {
        try {
           
            const response = await api.post("/books", bookData);
            return response.data;
        } catch (error) {
            return rejectWithValue(error.response?.data || "Error occurred");
        }
    }
);

export const deletBooks = createAsyncThunk(
    "books/deleteBooks", 
    async (bookId) => {
        try {
            const response = await api.delete("/books/"+bookId);
            return response.data;
        } 
        catch (error) {
            return error.response.data;
        } 
    }
);export const updateBooks = createAsyncThunk(
  "books/updateBooks",
  async ({ bookId, bookData }, thunkAPI) => {
    try {
      console.log("SENDING", bookData);

      const response = await api.put(
        `/books/${bookId}`,
        bookData
      );

      console.log("UPDATE RESPONSE", response.data);

      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);
export const getBooksWithDetails = createAsyncThunk("books/getBooksWithDetails",async (bookId,thunkApi) =>{
    try {
        const response = await api.get("/books/"+bookId);
        return response.data;
    }
    catch (error) {
        return thunkApi.rejectWithValue(error.response.data);
    }
});