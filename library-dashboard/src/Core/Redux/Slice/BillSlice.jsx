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
    .addCase(fetchBills.pending, (state) => {})
    .addCase(fetchBills.fulfilled, (state, action) => {})
    .addCase(fetchBills.rejected, (state, action) => {})
    

    .addCase(fetchBillsWithId.pending, (state) => {})
    .addCase(fetchBillsWithId.fulfilled, (state, action) => {})
    .addCase(fetchBillsWithId.rejected, (state, action) => {})    


    .addCase(fetchBillDelivery.pending, (state) => {})
    .addCase(fetchBillDelivery.fulfilled, (state, action) => {})
    .addCase(fetchBillDelivery.rejected, (state, action) => {})  

   
 
    
    }});

export default billSlice.reducer;