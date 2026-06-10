import {createSlice} from "@reduxjs/toolkit";
import {getTotoalbillsRevenue} from '../Thunks/FinanceThunk'
export const financeSlice = createSlice({
    name:"finance",
    initialState : {
        totalRevenue:null,
        loading: false,
        error: null,
    },
        reducers:{},
        extraReducers: (builder) =>{
builder
.addCase(getTotoalbillsRevenue.pending, (state) => {
    state.loading = true;
    state.error = null;
})
.addCase(getTotoalbillsRevenue.fulfilled, (state, action) => {
    state.loading = false;
    state.totalRevenue = action.payload;
})
.addCase(getTotoalbillsRevenue.rejected, (state, action) => {
    state.loading = false;
    state.error = action.payload;
})



        },
});
export default financeSlice.reducer;
