import { createSlice } from "@reduxjs/toolkit";
import { 
  getDashboardStats,
  getWeeklySales,
  getTopSellingBooks,
  getWeeklyBorrows 
} from "../Thunks/DashboardThunk";

const initialState = {
  dashboardStats: null,
  topSellingBooks: [],  
  weeklySales: null,    
  weeklyBorrows: null,  
  loading: false,
  error: null,
};

export const dashboardSlice = createSlice({
  name: "dashboard",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(getDashboardStats.fulfilled, (state, action) => {
        state.loading = false;
        state.dashboardStats = action.payload.data; 
      })

     .addCase(getWeeklySales.fulfilled, (state, action) => {
  state.loading = false;
  state.weeklySales = action.payload; 
})
.addCase(getWeeklyBorrows.fulfilled, (state, action) => {
  state.loading = false;
  state.weeklyBorrows = action.payload; 
})
.addCase(getTopSellingBooks.fulfilled, (state, action) => {
  state.loading = false;
  state.topSellingBooks = action.payload.data; 
})

      builder.addMatcher(
        (action) => action.type.endsWith('/pending'),
        (state) => { state.loading = true; state.error = null; }
      );
      builder.addMatcher(
        (action) => action.type.endsWith('/rejected'),
        (state, action) => { state.loading = false; state.error = action.error.message; }
      );
  },
});

export default dashboardSlice.reducer;