import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to images.
    public var services: ServicesAPI {
        .init(client: self)
    }
 
    public struct ServicesAPI {
        fileprivate var client: DockerClient
        
        /// Lists all services running in the Docker instance.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` of a list of `Service` instances.
        public func list() throws -> EventLoopFuture<[Service]> {
            try client.run(ListServicesEndpoint())
                .map({ services in
                    services.map { service in
                        service.toService()
                    }
                })
        }
        
        /// Updates a service with a new image.
        /// - Parameters:
        ///   - service: Instance of a `Service` that should be updated.
        ///   - newImage: Instance of an `Image` that should be used as the new image for the service.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` with the updated `Service`.
        public func update(service: Service, newImage: Image) throws -> EventLoopFuture<Service> {
            try client.run(UpdateServiceEndpoint(nameOrId: service.id.value, name: service.name, version: service.version, image: newImage.id.value))
                ._flatMap({ _ in
                    try self.get(serviceByNameOrId: service.id.value)
                })
        }
        
        /// Gets a service by a given name or id.
        /// - Parameter nameOrId: Name or id of a service that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Return an `EventLoopFuture` with the `Service`.
        public func get(serviceByNameOrId nameOrId: String) throws -> EventLoopFuture<Service> {
            try client.run(InspectServiceEndpoint(nameOrId: nameOrId))
                .map { service in
                    service.toService()
                }
        }
        
        /// Created a new service with a name and an image.
        /// This is the minimal way of creating a new service.
        /// - Parameters:
        ///   - name: Name of the new service.
        ///   - image: Instance of an `Image` for the service.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` with the newly created `Service`.
        public func create(serviceName name: String, image: Image) throws -> EventLoopFuture<Service> {
            try client.run(CreateServiceEndpoint(name: name, image: image.id.value))
                ._flatMap({ serviceId in
                    try client.run(InspectServiceEndpoint(nameOrId: serviceId.ID))
                })
                .map({ service in
                    service.toService()
                })
        }
    }
}

extension Service.ServiceResponse {
    
    /// Internal function that converts the response from Docker to the DockerClient representation.
    /// - Returns: Returns an instance of `Service` with the values of the current response.
    internal func toService() -> Service {
        Service(id: .init(self.ID), name: self.Spec.Name, createdAt: Date.parseDockerDate(self.CreatedAt), updatedAt: Date.parseDockerDate(self.UpdatedAt), version: self.Version.Index, image: Image(id: Identifier(self.Spec.TaskTemplate.ContainerSpec.Image)))
    }
}
