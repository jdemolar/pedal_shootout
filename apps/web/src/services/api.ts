import {
  PedalApiResponse,
  ManufacturerApiResponse,
  MidiControllerApiResponse,
  PedalboardApiResponse,
  PowerSupplyApiResponse,
  UtilityApiResponse,
} from '../types/api';

const API_BASE = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8081';

async function get<T>(path: string): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`);
  if (!res.ok) {
    throw new Error(`GET ${path} failed: ${res.status}`);
  }
  return res.json();
}

export const api = {
  getPedals: () => get<PedalApiResponse[]>('/api/pedals'),
  getPedal: (id: number) => get<PedalApiResponse>(`/api/pedals/${id}`),
  getManufacturers: () => get<ManufacturerApiResponse[]>('/api/manufacturers'),
  getMidiControllers: () => get<MidiControllerApiResponse[]>('/api/midi-controllers'),
  getMidiController: (id: number) => get<MidiControllerApiResponse>(`/api/midi-controllers/${id}`),
  getPedalboards: () => get<PedalboardApiResponse[]>('/api/pedalboards'),
  getPedalboard: (id: number) => get<PedalboardApiResponse>(`/api/pedalboards/${id}`),
  getPowerSupplies: () => get<PowerSupplyApiResponse[]>('/api/power-supplies'),
  getPowerSupply: (id: number) => get<PowerSupplyApiResponse>(`/api/power-supplies/${id}`),
  getUtilities: () => get<UtilityApiResponse[]>('/api/utilities'),
  getUtility: (id: number) => get<UtilityApiResponse>(`/api/utilities/${id}`),
};
