import { createSlice } from "@reduxjs/toolkit";

import {
  getDashboardStats,
  getWeeklySales,
  getTopSellingBooks,
  getWeeklyBorrows,
} from "../Thunks/DashboardThunk";

const initialState = {
  dashboardStats: null,

  topSellingBooks: [],

  weeklySales: null,

  weeklyBorrows: null,

  loading: false,
  loaded: false,

  lastFetched: null,

  error: null,
};

export const dashboardSlice = createSlice({
  name: "dashboard",

  initialState,

  reducers: {},

  extraReducers: (builder) => {
    builder

     
      .addCase(getDashboardStats.pending, (state) => {
        if (!state.dashboardStats) {
          state.loading = true;
        }

        state.error = null;
      })

      .addCase(getDashboardStats.fulfilled, (state, action) => {
        state.loading = false;
        state.loaded = true;

        state.dashboardStats = action.payload.data;

        state.lastFetched = Date.now();

        state.error = null;
      })

      .addCase(getDashboardStats.rejected, (state, action) => {
        state.loading = false;
        state.error =
          action.payload || action.error.message;
      })

     
      .addCase(getWeeklySales.fulfilled, (state, action) => {
        state.weeklySales = action.payload;
      })

    
      .addCase(getWeeklyBorrows.fulfilled, (state, action) => {
        state.weeklyBorrows = action.payload;
      })

     
      .addCase(
        getTopSellingBooks.fulfilled,
        (state, action) => {
          state.topSellingBooks =
            action.payload.data;
        }
      );
  },
});

export default dashboardSlice.reducer;