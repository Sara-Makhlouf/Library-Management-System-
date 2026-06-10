import { createAsyncThunk } from "@reduxjs/toolkit";
import axiosClient from "../../Api/aixos";

// Get All Transactions
export const getAllTransactions = createAsyncThunk(
  "adminTransactions/getAllTransactions",
  async (status = null, { rejectWithValue }) => {
    try {
      const response = await axiosClient.get(
        "/transactions",
        {
          params: status ? { status } : {},
        }
      );

      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data ||
          "Failed to fetch transactions"
      );
    }
  }
);

export const checkoutTransaction = createAsyncThunk(
  "adminTransactions/checkoutTransaction",
  async (checkoutData, { rejectWithValue }) => {
    try {
      const response = await axiosClient.post(
        "/transactions/checkout",
        checkoutData
      );

      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data ||
          "Failed to create transaction"
      );
    }
  }
);
