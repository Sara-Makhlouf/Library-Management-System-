import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";
export const getTotalPaidOrder = createAsyncThunk(
    "bill/getTotalPaidOrder",
  async ( thunkAPI) => {
    try{
        const response = await api.get("/statistics/total-paid-orders");
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response.data
    );
}
}  
);

export const getTotalBorrows = createAsyncThunk(
    "bill/getTotalBorrows",
async ( thunkAPI) => {
    try{
        const response = await api.get("/statistics/total-borrows");
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response.data
    );
}
  }  
);
