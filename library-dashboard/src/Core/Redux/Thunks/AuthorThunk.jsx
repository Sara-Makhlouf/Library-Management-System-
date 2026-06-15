import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";
export const getauthor = createAsyncThunk(
  "author/getauthor",
  async (_, thunkAPI) => {
    try {
      const response = await api.get("/authors");
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);

export const createauthor = createAsyncThunk(
  "author/createauthor",
  async (authorData, thunkAPI) => {
    try {
      const response = await api.post("/authors", authorData);
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);