import { createAsyncThunk } from "@reduxjs/toolkit";
import api from "../../Api/aixos";


const getAuthConfig = () => ({
  headers: {
    Authorization: `Bearer ${localStorage.getItem("admin_token")}`,
    Accept: "application/json",
  },
});

export const getAllTransactions = createAsyncThunk(
  "adminTransactions/getAllTransactions",
  async (status = null, { rejectWithValue }) => {
    try {
      const response = await api.get(
        `/transactions`,
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
      const response = await api.post(
        `/transactions/checkout`,
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