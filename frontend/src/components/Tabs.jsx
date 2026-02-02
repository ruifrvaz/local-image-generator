/**
 * Tabs Component (Radix-style interface)
 * Simple tab system for React
 */
import { createContext, useContext } from 'react';

const TabsContext = createContext();

export function Tabs({ value, onValueChange, children }) {
  return (
    <TabsContext.Provider value={{ value, onValueChange }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

export function TabsList({ children }) {
  return (
    <div className="flex space-x-1 border-b border-gray-200 mb-6">
      {children}
    </div>
  );
}

export function TabsTrigger({ value, children }) {
  const { value: activeValue, onValueChange } = useContext(TabsContext);
  const isActive = value === activeValue;

  return (
    <button
      onClick={() => onValueChange(value)}
      className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
        isActive
          ? 'border-blue-600 text-blue-600'
          : 'border-transparent text-gray-600 hover:text-gray-900'
      }`}
    >
      {children}
    </button>
  );
}

export function TabsContent({ value, children }) {
  const { value: activeValue } = useContext(TabsContext);
  
  if (value !== activeValue) return null;

  return <div className="tab-content">{children}</div>;
}
