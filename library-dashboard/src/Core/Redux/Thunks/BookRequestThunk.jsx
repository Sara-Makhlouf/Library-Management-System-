import { createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";


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
        `/book-requests/${requestId}/status`,
        {
          status,
          admin_note,
        },
     
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