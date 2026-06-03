import {createSlice} from "@reduxjs/toolkit";
import {getCategory , createCategory} from '../Thunks/CategoriesThunk'
export const categorySlice = createSlice({
    name:"category",
    initialState : {
        title:null,},
        reducers:{},
        extraReducers: (builder) =>{
builder
.addCase(getCategory.pending, (state, action) => {})
.addCase(getCategory.fulfilled, (state, action) => {})
.addCase(getCategory.rejected, (state, action) => {})

.addCase(createCategory.pending, (state, action) => {})
.addCase(createCategory.fulfilled, (state, action) => {})
.addCase(createCategory.rejected, (state, action) => {})

        },
});
export default categorySlice.reducer;