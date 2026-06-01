import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";
export const getauthor = createAsyncThunk(
    "category/getcategory",
  async ( thunkAPI) => {
    try{
        const response = await api.get("/categories/");
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response.data
    );
}
  }  
);
export const createcategory = createAsyncThunk(
    "author/createauthor",
  async (authorData, thunkAPI) => {
    try{
        const response = await api.post("/category", authorData);
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response.data
    );
}
  }  
);