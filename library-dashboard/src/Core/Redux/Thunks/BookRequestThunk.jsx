import { createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";


const getAuthConfig = () => ({
  headers: {
    Authorization: `Bearer ${localStorage.getItem("admin_token")}`,
    Accept: "application/json",
  },
});

export const updateBookRequestStatus = createAsyncThunk(
  "adminBookRequests/updateBookRequestStatus",
  async (
    {
      requestId,
      status,
      admin_note,
    },
    { rejectWithValue }
  ) => {
    try {
      const response = await axios.put(
        `/admin/book-requests/${requestId}/status`,
        {
          status,
          admin_note,
        },
        getAuthConfig()
      );

      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data ||
          "Failed to update book request status"
      );
    }
  }
);