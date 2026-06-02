import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";
export const getTotoalbillsRevenue = createAsyncThunk(
    "finance/gettotalbillsrevenue",
  async ( thunkAPI) => {
    try{
        const response = await api.get("/bills/total-revenue/");
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response.data
    );
}
  }  
);