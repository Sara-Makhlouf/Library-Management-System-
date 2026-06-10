import axios from "axios";
import { getAuthConfig } from "../../Api/aixos";
import { createApiThunk } from "../utils/reduxHelpers";

export const getAllSettings = createApiThunk(
  "adminSettings/getAllSettings",
  async () => {
    const response = await axios.get(`/admin/settings`, getAuthConfig());
    return response.data;
  }
);

export const updateSettings = createApiThunk(
  "adminSettings/updateSettings",
  async (settings) => {
    const response = await axios.post(
      `/admin/settings/update`,
      { settings },
      getAuthConfig()
    );
    return response.data;
  }
);

export const sendGlobalNotification = createApiThunk(
  "adminSettings/sendGlobalNotification",
  async (payload) => {
    const response = await axios.post(
      `/admin/notifications/global`,
      payload,
      getAuthConfig()
    );
    return response.data;
  }
);
