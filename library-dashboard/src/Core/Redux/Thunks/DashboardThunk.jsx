import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";

export const getDashboardStats = createAsyncThunk(
  "dashboard/getDashboardStats",
  async (thunkAPI) => {
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



export const getWeeklySales = createAsyncThunk(
  "dashboard/getWeeklySales",
  async ( thunkAPI) => {
    try {
      const response = await api.get("/statistics/weekly-sales");
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
  async ( thunkAPI) => {
    try {
      const response = await api.get("/statistics/top-selling-books");
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
  async ( thunkAPI) => {
    try {
      const response = await api.get("/statistics/weekly-borrows");
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);