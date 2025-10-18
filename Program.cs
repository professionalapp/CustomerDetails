using CustomerDetails.Models;
using Google.Cloud.Firestore;
using Google.Apis.Auth.OAuth2;
using FirebaseAdmin;
using System.IO;
using System.Text;
using Google.Cloud.Firestore.V1;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddControllers();

// Bind Kestrel to the hosting PORT if provided (e.g., Render)
var portEnv = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrWhiteSpace(portEnv))
{
    builder.WebHost.UseUrls($"http://0.0.0.0:{portEnv}");
}

// Firebase Initialization - START
try
{
    var firebaseServiceAccountJson = Environment.GetEnvironmentVariable("FIREBASE_SERVICE_ACCOUNT_JSON");
    if (!string.IsNullOrEmpty(firebaseServiceAccountJson))
    {
        // For production (Render.com) - use environment variable
        using (var stream = new MemoryStream(Encoding.UTF8.GetBytes(firebaseServiceAccountJson)))
        {
            FirebaseApp.Create(new AppOptions()
            {
                Credential = GoogleCredential.FromStream(stream)
            });
        }
    }
    else
    {
        // For local development, if the file is present in the project root.
        var serviceAccountPath = Path.Combine(builder.Environment.ContentRootPath, "employee-services-60fa4-firebase-adminsdk-o405k-d21a9b72c4.json");
        if (File.Exists(serviceAccountPath))
        {
            FirebaseApp.Create(new AppOptions()
            {
                Credential = GoogleCredential.FromFile(serviceAccountPath)
            });
        }
        else
        {
            Console.WriteLine("Warning: Firebase service account file not found and FIREBASE_SERVICE_ACCOUNT_JSON not set");
        }
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Firebase initialization error: {ex.Message}");
}
// Firebase Initialization - END

// Configure Firebase Firestore with explicit credentials
try
{
    // Resolve credentials from, in order: FIREBASE_SERVICE_ACCOUNT_JSON (inline JSON),
    // GOOGLE_APPLICATION_CREDENTIALS (path), or local file in content root.
    GoogleCredential? credential = null;

    var inlineServiceAccountJson = Environment.GetEnvironmentVariable("FIREBASE_SERVICE_ACCOUNT_JSON");
    var googleCredentialsPath = Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS");
    var localServiceAccountPath = Path.Combine(builder.Environment.ContentRootPath, "employee-services-60fa4-firebase-adminsdk-o405k-d21a9b72c4.json");

    if (!string.IsNullOrWhiteSpace(inlineServiceAccountJson))
    {
        credential = GoogleCredential.FromJson(inlineServiceAccountJson);
    }
    else if (!string.IsNullOrWhiteSpace(googleCredentialsPath) && File.Exists(googleCredentialsPath))
    {
        credential = GoogleCredential.FromFile(googleCredentialsPath);
    }
    else if (File.Exists(localServiceAccountPath))
    {
        credential = GoogleCredential.FromFile(localServiceAccountPath);
    }

    if (credential == null)
    {
        throw new InvalidOperationException("Firestore credentials not found. Set FIREBASE_SERVICE_ACCOUNT_JSON or GOOGLE_APPLICATION_CREDENTIALS, or include the service account file.");
    }

    if (credential.IsCreateScopedRequired)
    {
        credential = credential.CreateScoped(FirestoreClient.DefaultScopes);
    }

    var client = new FirestoreClientBuilder { Credential = credential }.Build();
    var firestoreDb = FirestoreDb.Create("employee-services-60fa4", client);
    builder.Services.AddSingleton(firestoreDb);
    Console.WriteLine("Firestore database initialized successfully (explicit credentials)");
}
catch (Exception ex)
{
    Console.WriteLine($"Firestore initialization error: {ex.Message}");
    // Keep failing fast here would break DI; the message explains how to fix env vars.
}

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

// إعدادات إضافية لملفات التصميم
app.UseDefaultFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();
app.MapControllers();

app.Run();
