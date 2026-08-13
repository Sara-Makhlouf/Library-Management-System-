import { createSlice } from "@reduxjs/toolkit";

import {
  fetchDeliveryOrders,
  updateDeliveryStatus,
} from "../Thunks/OrderThunk";

const initialState = {
  list: [],

  cache: {},

  loading: false,
  updateLoading: null,
  error: null,
};

const deliverySlice = createSlice({
  name: "delivery",

  initialState,

  reducers: {},

  extraReducers: (builder) => {
    builder

    
      .addCase(fetchDeliveryOrders.pending, (state) => {
        state.loading = true;
        state.error = null;
      })

      .addCase(fetchDeliveryOrders.fulfilled, (state, action) => {
        state.loading = false;

        const { data, status } = action.payload;

        state.cache[status] = data;

        state.list = data;
      })

      .addCase(fetchDeliveryOrders.rejected, (state, action) => {
        state.loading = false;

        state.error =
          action.payload ?? action.error.message;
      })

     
      .addCase(updateDeliveryStatus.pending, (state, action) => {
        state.updateLoading = action.meta.arg.id;
        state.error = null;
      })

      .addCase(updateDeliveryStatus.fulfilled, (state, action) => {
        state.updateLoading = null;

        const updated = action.payload.data;

        if (!updated) return;

      
        state.list = state.list.map((order) =>
          order.id === updated.id
            ? updated
            : order
        );

        
        Object.keys(state.cache).forEach((key) => {
          state.cache[key] = state.cache[key].map(
            (order) =>
              order.id === updated.id
                ? updated
                : order
          );
        });
      })

      .addCase(updateDeliveryStatus.rejected, (state, action) => {
        state.updateLoading = null;

        state.error =
          action.payload ?? action.error.message;
      });
  },
});

export default deliverySlice.reducer;