/**
 * Home Page - Image Generation Interface
 * Traceability: FUN-GEN-REQUEST, FUN-BATCH-GEN, FUN-SEQUENCE-GEN
 */
import { useState } from 'react';
import GenerationForm from '../components/GenerationForm';
import BatchGenerationForm from '../components/BatchGenerationForm';
import SequenceGenerationForm from '../components/SequenceGenerationForm';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '../components/Tabs';

function HomePage() {
  const [activeTab, setActiveTab] = useState('single');

  return (
    <div className="px-4 py-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Image Generation</h1>
        <p className="mt-2 text-sm text-gray-600">
          Create stunning AI-generated images using SDXL models
        </p>
      </div>

      {/* FUN-GEN-REQUEST-001: Generation mode tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="single">Single Image</TabsTrigger>
          <TabsTrigger value="batch">Batch Generation</TabsTrigger>
          <TabsTrigger value="sequence">Story Sequence</TabsTrigger>
        </TabsList>

        <TabsContent value="single">
          <GenerationForm />
        </TabsContent>

        <TabsContent value="batch">
          <BatchGenerationForm />
        </TabsContent>

        <TabsContent value="sequence">
          <SequenceGenerationForm />
        </TabsContent>
      </Tabs>
    </div>
  );
}

export default HomePage;
