import { initializeApp, getApps } from 'firebase/app';
import { getFirestore, enableIndexedDbPersistence } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';

export const firebaseConfig = {
  apiKey: "AIzaSyCXSpa32bojm9N59WhsygtDCi35QKcl0_0",
  authDomain: "clinicflow-app-4281.firebaseapp.com",
  projectId: "clinicflow-app-4281",
  storageBucket: "clinicflow-app-4281.firebasestorage.app",
  messagingSenderId: "903972374275",
  appId: "1:903972374275:web:79d4fb90614608e0c04b36"
};

let app = null;
let db = null;
let auth = null;
let isFirebaseInitialized = false;

try {
  if (!getApps().length) {
    app = initializeApp(firebaseConfig);
  } else {
    app = getApps()[0];
  }
  db = getFirestore(app);
  auth = getAuth(app);
  isFirebaseInitialized = true;
} catch (error) {
  console.warn("Firebase initialization warning (fallback to local mock engine active):", error);
}

export { app, db, auth, isFirebaseInitialized };
