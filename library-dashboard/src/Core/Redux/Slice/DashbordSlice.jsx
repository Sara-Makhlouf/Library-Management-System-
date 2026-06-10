import { createSlice } from "@reduxjs/toolkit";
import {
  getDashboardStats,
  getTopBorrowed,
  getWeeklySales,
  getTopSellingBooks,
  getWeeklyBorrows,
} from "../Thunks/DashboardThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

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
    addAsyncCases(builder, getDashboardStats, { dataKey: "dashboardStats" });
    addAsyncCases(builder, getTopBorrowed, { dataKey: "topBorrowedBooks" });
    addAsyncCases(builder, getWeeklySales, { dataKey: "weeklySales" });
    addAsyncCases(builder, getTopSellingBooks, { dataKey: "topSellingBooks" });
    addAsyncCases(builder, getWeeklyBorrows, { dataKey: "weeklyBorrows" });
  },
});

export default dashboardSlice.reducer;
