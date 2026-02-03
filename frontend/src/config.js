/**
 * Frontend Configuration Module
 * Loads configuration from Vite environment variables
 * Traceability: STK-CONFIG-005, STK-CONFIG-006, STK-CONFIG-010
 */

// STK-CONFIG-006: Frontend accesses config via import.meta.env.VITE_*
// STK-CONFIG-010: Provides fallback default if not set
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';

// Log warning if configuration not set
if (!import.meta.env.VITE_API_BASE_URL) {
  console.warn('VITE_API_BASE_URL not set in .env, using default:', API_BASE_URL);
}

export const config = {
  apiBaseUrl: API_BASE_URL,
  apiBase: `${API_BASE_URL}/api`,
};

export default config;
