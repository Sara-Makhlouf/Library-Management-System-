import {  createAsyncThunk, } from "@reduxjs/toolkit";
import api from "../../Api/aixos";


export const fetchBooks = createAsyncThunk(
    "books/fetchBooks", 
async (_, thunkAPI) => {
try {
    const response = await api.get("/books");
    return response.data;
}
catch(error) {
    return thunkAPI.rejectWithValue(error.response?.data || error.message);
}
}
);

export const createBooks = createAsyncThunk(
    "books/createBooks",
    async (bookData, thunkAPI) => {
        try {
            const response = await api.post("/books", bookData);
            return response.data;
        }
        catch (error) {
            return thunkAPI.rejectWithValue(error.response?.data || error.message);
        }
    }
);

export const deletBooks = createAsyncThunk(
    "books/deleteBooks", 
    async (bookId, thunkAPI) => {
        try {
            const response = await api.delete("/books/"+bookId);
            return response.data;
        } 
        catch (error) {
            return thunkAPI.rejectWithValue(error.response?.data || error.message);
        } 
    }
);

 export const updateBooks = createAsyncThunk(
    "books/updateBooks", 
        async (bookData, thunkAPI) =>{
            try{
                const response = await api.put("/books/"+bookData.id, bookData);
                return response.data;
            }
            catch(error){
                return thunkAPI.rejectWithValue(error.response?.data || error.message);
            }
        } 
 );
 
 export const getBook = createAsyncThunk("books/getBookById",async (bookId, thunkAPI) => {
try {
const response = await api.get("/books/"+bookId);
return response.data;
}
catch(error){
    return thunkAPI.rejectWithValue(error.response?.data || error.message);
}
 });
export const getBooksWithDetails = createAsyncThunk("books/getBooksWithDetails",async (bookId,thunkApi) =>{
    try {
        const response = await api.get("/books/"+bookId);
        return response.data;
    }
    catch (error) {
        return thunkApi.rejectWithValue(error.response?.data || error.message);
    }
});
