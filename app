import React, { useState } from 'react';
import {
  XCircleIcon,
  CheckCircleIcon,
  DocumentTextIcon
} from '@heroicons/react/24/outline';

// Load Heroicons and Tailwind CSS via CDN (assumed available in this environment)
// You would typically install these via npm in a real-world app.
// For this immersive, we assume they are available.
// A note about PapaParse: it's a great lightweight CSV parser for the browser.
// <script src="https://unpkg.com/papaparse@5.3.0/papaparse.min.js"></script>
// We'll use the 'Papa' global object for this.

// Regular expressions for validation
const thaiIdRegex = /^\d{13}$/;
const thaiCharactersRegex = /[\u0E00-\u0E7F]+/;

// This is the main application component
const App = () => {
  const [csvData, setCsvData] = useState([]);
  const [validationResults, setValidationResults] = useState([]);
  const [file, setFile] = useState(null);

  // Function to validate Thai ID Card using the checksum algorithm
  const validateThaiId = (id) => {
    // Check if the ID is a 13-digit number
    if (!thaiIdRegex.test(id)) {
      return false;
    }
    const digits = id.split('').map(Number);
    // Checksum algorithm
    let sum = 0;
    for (let i = 0; i < 12; i++) {
      sum += digits[i] * (13 - i);
    }
    const checksum = sum % 11;
    const lastDigit = (11 - checksum) % 10;
    return digits[12] === lastDigit;
  };

  // Function to validate Thai Address
  const validateThaiAddress = (address) => {
    // A simple validation: check if it contains Thai characters and is not empty.
    return !!address && thaiCharactersRegex.test(address);
  };

  // Function to validate Full Name (Thai)
  const validateFullName = (name) => {
    // A simple validation: check for Thai characters, a space (for first/last name), and not empty.
    return !!name && thaiCharactersRegex.test(name) && name.includes(' ');
  };

  // Handles the file upload and parsing
  const handleFileChange = (e) => {
    const uploadedFile = e.target.files[0];
    if (uploadedFile) {
      setFile(uploadedFile);
      Papa.parse(uploadedFile, {
        header: true,
        skipEmptyLines: true,
        complete: (result) => {
          setCsvData(result.data);
          validateData(result.data);
        },
      });
    }
  };

  // Main validation function
  const validateData = (data) => {
    const results = data.map((row) => {
      // Find the correct keys for the fields (e.g., 'thaiid', 'id card', 'เลขบัตรประชาชน')
      const idKey = Object.keys(row).find(key => key.toLowerCase().includes('id') || key.toLowerCase().includes('บัตร'));
      const addressKey = Object.keys(row).find(key => key.toLowerCase().includes('address') || key.toLowerCase().includes('ที่อยู่'));
      const nameKey = Object.keys(row).find(key => key.toLowerCase().includes('name') || key.toLowerCase().includes('ชื่อ'));

      const thaiId = row[idKey] || '';
      const thaiAddress = row[addressKey] || '';
      const fullName = row[nameKey] || '';

      return {
        originalRow: row,
        isIdValid: validateThaiId(thaiId.trim()),
        isAddressValid: validateThaiAddress(thaiAddress.trim()),
        isNameValid: validateFullName(fullName.trim()),
      };
    });
    setValidationResults(results);
  };

  // A component to display a validation status icon
  const ValidationIcon = ({ isValid }) => {
    return isValid ? (
      <CheckCircleIcon className="w-5 h-5 text-green-500" />
    ) : (
      <XCircleIcon className="w-5 h-5 text-red-500" />
    );
  };

  return (
    <div className="min-h-screen bg-gray-100 p-8 font-sans antialiased">
      <div className="max-w-4xl mx-auto bg-white p-8 rounded-2xl shadow-xl">
        <h1 className="text-4xl font-extrabold text-center text-gray-800 mb-2">CSV Validator</h1>
        <p className="text-center text-gray-500 mb-8">Validate Thai data from a CSV file.</p>
        
        <div className="flex flex-col items-center justify-center border-2 border-dashed border-gray-300 rounded-xl p-8 mb-8 hover:border-blue-500 transition-colors duration-200 cursor-pointer">
          <DocumentTextIcon className="w-12 h-12 text-gray-400 mb-4" />
          <p className="text-gray-600 mb-2">Drag & drop your CSV file here or click to upload.</p>
          <input
            type="file"
            accept=".csv"
            onChange={handleFileChange}
            className="absolute inset-0 opacity-0 cursor-pointer"
          />
        </div>
        
        {file && (
          <div className="text-center text-sm text-gray-600 mb-4">
            <p>Uploaded file: <span className="font-semibold text-blue-600">{file.name}</span></p>
            <p>
              Validation Summary: {' '}
              <span className="font-semibold">
                {validationResults.filter(r => r.isIdValid && r.isAddressValid && r.isNameValid).length}
              </span>{' '}
              of{' '}
              <span className="font-semibold">
                {validationResults.length}
              </span>{' '}
              rows are valid.
            </p>
          </div>
        )}

        {validationResults.length > 0 && (
          <div className="overflow-x-auto rounded-xl shadow-md">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    #
                  </th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Full Name (Thai)
                  </th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Thai ID Card
                  </th>
                  <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Thai Address
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {validationResults.map((result, index) => (
                  <tr key={index} className="hover:bg-gray-50 transition-colors duration-100">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{index + 1}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div className="flex items-center space-x-2">
                        <ValidationIcon isValid={result.isNameValid} />
                        <span>{Object.values(result.originalRow)[Object.keys(result.originalRow).findIndex(key => key.toLowerCase().includes('name') || key.toLowerCase().includes('ชื่อ'))]}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div className="flex items-center space-x-2">
                        <ValidationIcon isValid={result.isIdValid} />
                        <span>{Object.values(result.originalRow)[Object.keys(result.originalRow).findIndex(key => key.toLowerCase().includes('id') || key.toLowerCase().includes('บัตร'))]}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div className="flex items-center space-x-2">
                        <ValidationIcon isValid={result.isAddressValid} />
                        <span>{Object.values(result.originalRow)[Object.keys(result.originalRow).findIndex(key => key.toLowerCase().includes('address') || key.toLowerCase().includes('ที่อยู่'))]}</span>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default App;
