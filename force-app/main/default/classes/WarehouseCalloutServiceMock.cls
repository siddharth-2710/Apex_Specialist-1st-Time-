@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        
        System.assertEquals('https://th-superbadge-apex.herokuapp.com/equipment', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());
        
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"name":"Fuse 8A", "_id":"55d66226726b611100aaf740", "replacement":true, "quantity":194, "maintenanceperiod":0, "lifespan":0, "cost":5, "sku":"100002"}]');
        response.setStatusCode(200);
        return response; 
    }
}