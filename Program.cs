using CustomerDetails.Models;
using Google.Cloud.Firestore;
using Google.Apis.Auth.OAuth2;
using FirebaseAdmin;
using System.IO;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddControllers();

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

// Configure Firebase Firestore
try
{
    FirestoreDb firestoreDb = FirestoreDb.Create("employee-services-60fa4");
    builder.Services.AddSingleton(firestoreDb);
    Console.WriteLine("Firestore database initialized successfully");
}
catch (Exception ex)
{
    Console.WriteLine($"Firestore initialization error: {ex.Message}");
    // Continue without Firestore if it fails
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

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();
app.MapControllers();

app.Run();
