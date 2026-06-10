import { createSlice } from "@reduxjs/toolkit";
//for crude operation 
import { fetchBills ,fetchBillsWithId,fetchBillDelivery
 } from "../Thunks/BillThunk";

const billSlice = createSlice({
    name:"bill",
initialState:{
billSlice: [],
error: null,
loading:false,

},
    extraReducers : (builder) => {
        builder 
    .addCase(fetchBills.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(fetchBills.fulfilled, (state, action) => {
        state.loading = false;
        state.billSlice = action.payload;
    })
    .addCase(fetchBills.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })
    

    .addCase(fetchBillsWithId.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(fetchBillsWithId.fulfilled, (state, action) => {
        state.loading = false;
        state.billSlice = action.payload;
    })
    .addCase(fetchBillsWithId.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })    


    .addCase(fetchBillDelivery.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(fetchBillDelivery.fulfilled, (state, action) => {
        state.loading = false;
        state.billSlice = action.payload;
    })
    .addCase(fetchBillDelivery.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })  

   
 
    
    }});

export default billSlice.reducer;
