import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";
export const getCategory = createAsyncThunk(
    "category/getcategory",
  async (_, thunkAPI) => {
    try{
        const response = await api.get("/categories");
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response.data
    );
}
  }  
);
export const createCategory = createAsyncThunk(
    "category/createcategory",
  async (categoryData, thunkAPI) => {
    try{
        const response = await api.post("/categories", categoryData);
        return response.data;
    }
catch(error){
    return thunkAPI.rejectWithValue(
        error.response.data
    );
}
  }  
);
export const deleteCategory = createAsyncThunk(
  "category/deleteCategory",
  async (id, thunkAPI) => {
    try {
      await api.delete(`/categories/${id}`);
      return id; 
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data || error.message);
    }
  }
);

export const updateCategory = createAsyncThunk(
  "category/updateCategory",
  async ({ id, categoryData }, thunkAPI) => {
    try {
      const response = await api.put(`/categories/${id}`, categoryData);
      return response.data; 
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data || error.message);
    }
  }
);