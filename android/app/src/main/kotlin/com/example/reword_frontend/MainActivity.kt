package com.example.reword_frontend

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.reword_frontend/auth"
    private var flutterEngine: FlutterEngine? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.flutterEngine = flutterEngine
    }
    
    // Handle deep link opening
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent) // Important to update the intent
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent) {
        val action = intent.action
        val data = intent.data
        
        if (Intent.ACTION_VIEW == action && data != null) {
            val uri = data.toString()
            Log.d("MainActivity", "Deep link received: $uri")
            
            // Check if this is a Google auth callback
            if (uri.contains("google-auth-success")) {
                try {
                    val parsedUri = Uri.parse(uri)
                    val token = parsedUri.getQueryParameter("token")
                    
                    if (token != null) {
                        Log.d("MainActivity", "Found token: $token")
                        
                        // Send the token to Flutter
                        if (flutterEngine != null) {
                            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                                .invokeMethod("handleGoogleToken", token)
                        } else {
                            Log.e("MainActivity", "FlutterEngine is null")
                        }
                    } else {
                        Log.e("MainActivity", "No token in URI")
                    }
                } catch (e: Exception) {
                    Log.e("MainActivity", "Error parsing URI: ${e.message}")
                }
            }
        }
    }
}