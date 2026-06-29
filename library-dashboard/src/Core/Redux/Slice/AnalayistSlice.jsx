import { createSlice } from "@reduxjs/toolkit";
import { getTotalPaidOrder, getTotalBorrows } from "../Thunks/AnalayistThunk";

const initialState = {
  totalPaidOrder: null,
  totalBorrows: null,
  loading: false,
  error: null,
};

const analystSlice = createSlice({
  name: "analyst",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(getTotalPaidOrder.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getTotalPaidOrder.fulfilled, (state, action) => {
        state.loading = false;
        state.totalPaidOrder = action.payload;
      })
      .addCase(getTotalPaidOrder.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      .addCase(getTotalBorrows.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getTotalBorrows.fulfilled, (state, action) => {
        state.loading = false;
        state.totalBorrows = action.payload;
      })
      .addCase(getTotalBorrows.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export default analystSlice.reducer;