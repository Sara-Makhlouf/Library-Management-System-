import {createSlice} from "@reduxjs/toolkit";
import {getDashboardStats,getTopBorrowed,getWeeklySales,getTopSellingBooks,getWeeklyBorrows} from "";
export const dashboardSlice = createSlice({
    name:"dashboard",
    initialState:{},
    reducers:{},
    extraReducers:(builder) =>{
        builder 
//1  
        .addCase(getDashboardStats.pending,(state) =>{})
        .addCase(getDashboardStats.fulfilled,(state, action) =>{})
        .addCase(getDashboardStats.rejected,(state, action) =>{})
//2
        .addCase(getTopBorrowed.pending,(state) =>{})
        .addCase(getTopBorrowed.fulfilled,(state, action) =>{})
        .addCase(getTopBorrowed.rejected,(state, action) =>{})

//3
  
        
        .addCase(getWeeklySales.pending,(state) =>{})
        .addCase(getWeeklySales.fulfilled,(state, action) =>{})
        .addCase(getWeeklySales.rejected,(state, action) =>{})
//4
        .addCase(getTopSellingBooks.pending,(state) =>{})
        .addCase(getTopSellingBooks.fulfilled,(state, action) =>{})
        .addCase(getTopSellingBooks.rejected,(state, action) =>{})
//5

        .addCase(getWeeklyBorrows.pending,(state) =>{})
        .addCase(getWeeklyBorrows.fulfilled,(state, action) =>{})
        .addCase(getWeeklyBorrows.rejected,(state, action) =>{})

       

    }
});