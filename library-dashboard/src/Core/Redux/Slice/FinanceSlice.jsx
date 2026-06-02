import {createSlice} from "@reduxjs/toolkit";
import {getTotoalbillsRevenue} from '../Thunks/FinanceThunk'
export const financeSlice = createSlice({
    name:"finance",
    initialState : {
        totalRevenue:null,},
        reducers:{},
        extraReducers: (builder) =>{
builder
.addCase(getTotoalbillsRevenue.pending, (state, action) => {})
.addCase(getTotoalbillsRevenue.fulfilled, (state, action) => {})
.addCase(getTotoalbillsRevenue.rejected, (state, action) => {})



        },
});
export default financeSlice.reducer;