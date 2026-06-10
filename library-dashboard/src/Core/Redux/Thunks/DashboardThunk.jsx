import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";

export const getDashboardStats = createAsyncThunk(
  "dashboard/getDashboardStats",
  async (_, thunkAPI) => {
    try {
      const response = await api.get(`/dashboard-stats`);
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);

export const getTopBorrowed = createAsyncThunk(
  "dashboard/getTopBorrowed",
  async (_, thunkAPI) => {
    try {
      const response = await api.post("/transactions/top-borrowed");
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);


export const getWeeklySales = createAsyncThunk(
  "dashboard/getWeeklySales",
  async (_, thunkAPI) => {
    try {
      const response = await api.post("/statistics/weekly-sales");
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);



export const getTopSellingBooks = createAsyncThunk(
  "dashboard/getTopSellingBooks",
  async (_, thunkAPI) => {
    try {
      const response = await api.post("/statistics/top-selling-books");
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);


export const getWeeklyBorrows = createAsyncThunk(
  "dashboard/getWeeklyBorrows",
  async (_, thunkAPI) => {
    try {
      const response = await api.post("/statistics/weekly-borrows");
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);
