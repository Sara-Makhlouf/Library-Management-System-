import { createAsyncThunk } from "@reduxjs/toolkit";
import api from "../../Api/aixos";

export const fetchBookRequests = createAsyncThunk(
  "bookRequests/fetchBookRequests",

  async (status = "pending", { rejectWithValue }) => {
    try {
      const response = await api.get("/book-requests", {
        params: { status },
      });

     

      return response.data.data || [];
    } catch (error) {
      return rejectWithValue(
        error.response?.data || {
          message: "Failed to fetch book requests",
        }
      );
    }
  }
);


export const updateBookRequestStatus = createAsyncThunk(
  "adminBookRequests/updateBookRequestStatus",

  async (
    {
      requestId,
      status,
      admin_note = "",
    },
    { rejectWithValue }
  ) => {
    try {
      const response = await api.put(
        `/book-requests/${requestId}/status`,
        {
          status,
          admin_note,
        }
      );

      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data || {
          message: "Failed to update book request status",
        }
      );
    }
  }
);