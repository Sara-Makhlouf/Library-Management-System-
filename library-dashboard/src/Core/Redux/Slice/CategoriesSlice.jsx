import {createSlice} from "@reduxjs/toolkit";
import {getCategory , createCategory} from '../Thunks/CategoriesThunk'
export const categorySlice = createSlice({
    name:"category",
    initialState : {
        title:null,
        loading: false,
        error: null,
    },
        reducers:{},
        extraReducers: (builder) =>{
builder
.addCase(getCategory.pending, (state) => {
    state.loading = true;
    state.error = null;
})
.addCase(getCategory.fulfilled, (state, action) => {
    state.loading = false;
    state.title = action.payload;
})
.addCase(getCategory.rejected, (state, action) => {
    state.loading = false;
    state.error = action.payload;
})

.addCase(createCategory.pending, (state) => {
    state.loading = true;
    state.error = null;
})
.addCase(createCategory.fulfilled, (state, action) => {
    state.loading = false;
})
.addCase(createCategory.rejected, (state, action) => {
    state.loading = false;
    state.error = action.payload;
})

        },
});
export default categorySlice.reducer;
