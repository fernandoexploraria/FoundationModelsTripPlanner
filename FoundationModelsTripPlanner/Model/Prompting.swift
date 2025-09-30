import Playgrounds
import FoundationModels

#Playground {
    let session = LanguageModelSession()
    _ = try await session.respond(to: "Create and Itinerary to Joshua Tree")
}
