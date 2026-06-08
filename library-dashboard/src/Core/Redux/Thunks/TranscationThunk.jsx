import { createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";


const getAuthConfig = () => ({
  headers: {
    Authorization: `Bearer ${localStorage.getItem("admin_token")}`,
    Accept: "application/json",
  },
});

// Get All Transactions
export const getAllTransactions = createAsyncThunk(
  "adminTransactions/getAllTransactions",
  async (status = null, { rejectWithValue }) => {
    try {
      const response = await axios.get(
        `/admin/transactions`,
        {
          ...getAuthConfig(),
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
;

export const checkoutTransaction = createAsyncThunk(
  "adminTransactions/checkoutTransaction",
  async (checkoutData, { rejectWithValue }) => {
    try {
      const response = await axios.post(
        `/admin/transactions/checkout`,
        checkoutData,
        getAuthConfig()
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