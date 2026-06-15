import { createAsyncThunk } from "@reduxjs/toolkit";
import api from "../../Api/aixos";
export const getBooksInvaliable = createAsyncThunk(
  "waitingList/getBooksInvaliable",
  async (_, thunkAPI) => {
    try {
      const response = await api.get("/waiting-list");
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data
      );
    }
  }
);
export default getBooksInvaliable;
   export const deleteFromWatingList = createAsyncThunk("watinglist/deletwatinglist",
async (waitId,thunkAPI)=>{
  try{
    const response = await api.delete("/waiting-list/"+waitId);
    return response.data;
  }
  catch (error){
 return thunkAPI.rejectWithValue(
        error.response?.data
      );
  }
}
   );
   export const getTopWaitingList = createAsyncThunk("waitinglist/gettop",
    async(_,thunkAPI)=>{
      try {
        const response = await api.get("/waiting-list/top");
      return  response.data.data;
      }
      catch(error){

      }
    }
   );