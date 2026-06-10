import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";
export const fetchBills = createAsyncThunk(
    "bill/fetchbills",
  async (_, thunkAPI) => {
    try{
        const response = await api.get("/bills");
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response?.data || error.message
    );
}
  }  
);
export const fetchBillsWithId = createAsyncThunk(
    "bill/fetchbillswithid",
  async (billId, thunkAPI) => {
    try{
        const response = await api.get(`/bills/${billId}`);
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response?.data || error.message
    );
}
  }  
);
export const fetchBillDelivery = createAsyncThunk(
    "bill/fetchbilldelivery",
  async (billId, thunkAPI) => {
    try{
        const response = await api.get(`/bills/delivery-requests`);
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response?.data || error.message
    );
}
  }  
);
