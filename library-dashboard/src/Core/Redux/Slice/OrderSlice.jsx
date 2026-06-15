import { createSlice } from "@reduxjs/toolkit";
import { fetchDeliveryOrders, updateDeliveryStatus } from "../Thunks/OrderThunk";

const deliverySlice = createSlice({
  name: "delivery",
  initialState: {
    list: [],
    loading: false,
    updateLoading: null, 
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchDeliveryOrders.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchDeliveryOrders.fulfilled, (state, action) => {
        state.loading = false;
        state.list = action.payload.data;
      })
      .addCase(fetchDeliveryOrders.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload ?? action.error.message;
      })

      .addCase(updateDeliveryStatus.pending, (state, action) => {
        state.updateLoading = action.meta.arg.id;
        state.error = null;
      })
      .addCase(updateDeliveryStatus.fulfilled, (state, action) => {
        state.updateLoading = null;
        const updated = action.payload.data;
        state.list = state.list.map((b) =>
          b.id === updated.id ? updated : b
        );
      })
      .addCase(updateDeliveryStatus.rejected, (state, action) => {
        state.updateLoading = null;
        state.error = action.payload ?? action.error.message;
      });
  },
});

export default deliverySlice.reducer;