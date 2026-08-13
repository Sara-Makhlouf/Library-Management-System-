import { createAsyncThunk } from "@reduxjs/toolkit";
import api from "../../Api/aixos";

export const fetchDeliveryOrders = createAsyncThunk(
  "delivery/fetchDeliveryOrders",

  async (status = null, thunkAPI) => {
    try {
      const params = status ? { status } : {};

      const response = await api.get("/delivery-requests", {
        params,
      });

      return {
        data: response.data.data || [],
        status: status || "all",
      };
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  },

  {
    condition: (status = null, { getState }) => {
      const state = getState().delivery;

      const key = status || "all";

      if (state.cache?.[key]?.length > 0) {
        return false;
      }

      if (state.loading) {
        return false;
      }

      return true;
    },
  }
);

export const updateDeliveryStatus = createAsyncThunk(
  "delivery/updateDeliveryStatus",

  async ({ id, delivery_status }, thunkAPI) => {
    try {
      const response = await api.patch(
        `/bills/${id}/${delivery_status}`
      );

      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);