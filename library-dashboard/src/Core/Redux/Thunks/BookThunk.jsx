import {  createAsyncThunk, } from "@reduxjs/toolkit";
import api from "../../Api/aixos";


export const fetchBooks = createAsyncThunk(
    "books/fetchBooks", 
async () => {
try {
    const response = await api.get("/books");
    return response.data;
}
catch(error) {
    return error.response.data;
}
}
);

export const createBooks = createAsyncThunk(
    "books/createBooks",
    async (bookData) => {
        try {
            const response = await api.post("/books", bookData);
            return response.data;
        }
        catch (error) {
            return error.response.data;
        }
    }
);

export const deletBooks = createAsyncThunk(
    "books/deleteBooks", 
    async (bookId) => {
        try {
            const response = await api.delete("/books/"+bookId);
            return response.data;
        } 
        catch (error) {
            return error.response.data;
        } 
    }
);

 export const updateBooks = createAsyncThunk(
    "books/updateBooks", 
        async (bookData,bookId) =>{
            try{
                const response = await api.put("/books/"+bookId,bookData);
                return response.data;
            }
            catch(error){
         return error.response.data;
            }
        } 
 );
 
 export const getBook = createAsyncThunk("books/getBookById",async (bookId) => {
try {
const response = await api.get("/books/"+bookId);
return response.data;
}
catch(error){
    return error.response.data;
}
 });
