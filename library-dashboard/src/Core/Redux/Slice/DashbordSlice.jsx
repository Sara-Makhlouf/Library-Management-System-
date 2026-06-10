import { createSlice } from "@reduxjs/toolkit";
import { 
  getDashboardStats,
  getTopBorrowed,
  getWeeklySales,
  getTopSellingBooks,
  getWeeklyBorrows 
} from "../Thunks/DashboardThunk";

const initialState = {
  dashboardStats: null,
  topBorrowedBooks: [],
  topSellingBooks: [],
  weeklySales: [],
  weeklyBorrows: [],
  loading: false,
  error: null,
};

export const dashboardSlice = createSlice({
  name: "dashboard",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      //Dashboard Stats
      .addCase(getDashboardStats.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getDashboardStats.fulfilled, (state, action) => {
        state.loading = false;
        state.dashboardStats = action.payload;
      })
      .addCase(getDashboardStats.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      //Top Borrowed Books 
      .addCase(getTopBorrowed.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getTopBorrowed.fulfilled, (state, action) => {
        state.loading = false;
        state.topBorrowedBooks = action.payload;
      })
      .addCase(getTopBorrowed.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      // Weekly Sales 
      .addCase(getWeeklySales.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getWeeklySales.fulfilled, (state, action) => {
        state.loading = false;
        state.weeklySales = action.payload;
      })
      .addCase(getWeeklySales.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      //Top Selling Books 
      .addCase(getTopSellingBooks.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getTopSellingBooks.fulfilled, (state, action) => {
        state.loading = false;
        state.topSellingBooks = action.payload;
      })
      .addCase(getTopSellingBooks.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      // Weekly Borrows 
      .addCase(getWeeklyBorrows.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getWeeklyBorrows.fulfilled, (state, action) => {
        state.loading = false;
        state.weeklyBorrows = action.payload;
      })
      .addCase(getWeeklyBorrows.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      });
  },
});

export default dashboardSlice.reducer;