import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";

const getAuthConfig = () => ({
  headers: {
    Authorization: `Bearer ${localStorage.getItem("admin_token")}`,
    Accept: "application/json",
  },
});

export const fetchBills = createAsyncThunk(
  "bills/fetchBills",
  async ({ page = 1 } = {}, { rejectWithValue }) => {
    try {
      const response = await api.get("/bills", {
        ...getAuthConfig(),
        params: { page },
      });
      return response.data.data;
    } catch (err) {
      return rejectWithValue(err.response?.data || "Failed");
    }
  }
);

export const fetchBillDetails = createAsyncThunk(
  "bills/fetchBillDetails",
  async (billId, { rejectWithValue }) => {
    try {
      const response = await api.get(`/bills/${billId}`, getAuthConfig());
      return response.data.data;
    } catch (err) {
      return rejectWithValue(err.response?.data || "Failed");
    }
  }
);