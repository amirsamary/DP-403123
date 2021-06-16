ROUTINE SDSMACROS [Type=INC]

    //#define ThrowStatusExceptionIfError(%Name,%Status) If $System.Status.IsError(tSC) Set tFaultCode=$Piece($Piece($System.Status.GetErrorText(tSC),"faultcode=",2),$C(13)) Set tFaultActor=$Piece($Piece($System.Status.GetErrorText(tSC),"faultactor=",2),$C(13)) Set e = ##class(%Exception.StatusException).CreateFromStatus(%Status) If tFaultCode'="" { Set e.Name=tFaultCode,e.Location=tFaultActor}	Throw e
    #define ThrowStatusExceptionIfError(%Status, %Name)	Do ##class(SDS.Util.ExceptionSupport).ThrowStatusExceptionIfError(%Status, %Name)

    #define ThrowSQLExceptionIfError(%Name)	If SQLCODE<0 Do ##class(SDS.Util.ExceptionSupport).ThrowSQLExceptionIfError(SQLCODE, %msg, %Name)

    #define ThrowSQLExceptionIfResultError(%oSQLResultStatement, %Name)	If %oSQLResultStatement.%SQLCODE<0 Do ##class(SDS.Util.ExceptionSupport).ThrowSQLExceptionIfError(%oSQLResultStatement.%SQLCODE, %oSQLResultStatement.%Message, %Name)

    #define ThrowException(%Name,%Details) Set e = ##class(%Exception.General).%New(%Name, %Name,,%Details) Throw e

    //#define SOAPFaultWithException(%e) If %e.%ClassName()="StatusException"	{ Set f = ##class(%SOAP.WebService).MakeStatusFault(%e.Name, %e.Code, %e.AsStatus(), $System) } Else { Set f = ##class(%SOAP.WebService).MakeFault(%e.Name, %e.Code, $System)	} Do ##class(%SOAP.WebService).ReturnFault(f) 
    #define SOAPFaultWithException(%exception)	Do ##class(SDS.Util.ExceptionSupport).SOAPFaultWithException(%exception)

    #define ExceptionAsJSON(%exception) ##class(SDS.Util.ExceptionSupport).ExceptionAsJSON(%exception)

    // This macro deserializes the JSON string in customerInfo into a variable defined by %paramName
    // of type %className.
    //
    // This is better than using our dynamic objects because it will use the class's schema to validate
    // the fields in the json:
    // - Dates must be valid. 
    // - Strings must have the right length. 
    // - Numbers must be numbers.
    // - Required fields must have values
    // - Booleans must be also valid
    // - etc.
    //
    // If any of these validations fail, the macro will RETURN with a 400 Bad Request and information
    // about the problematic field
    #define JSONDeserialize(%paramName, %className, %deserObj) Set %deserObj=$classmethod(%className,"%New") Set status = %deserObj.%JSONImport(%paramName) If $$$ISERR(status) { Do ..%ReportRESTError(400, status) Return "" }