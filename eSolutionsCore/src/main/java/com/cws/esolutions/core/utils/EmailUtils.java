/*
 * Copyright (c) 2009 - 2020 CaspersBox Web Services
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.cws.esolutions.core.utils;
/*
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.core.utils
 * File: EmailUtils.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * cws-khuntly          11/23/2008 22:39:20             Created.
 */
import java.util.Map;
import java.util.List;
import javax.mail.Part;
import org.slf4j.Logger;
import javax.mail.Store;
import javax.mail.Flags;
import java.util.HashMap;
import javax.mail.Folder;
import java.util.Calendar;
import javax.mail.Session;
import javax.mail.Message;
import javax.mail.URLName;
import javax.mail.Address;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import javax.mail.BodyPart;
import javax.mail.Transport;
import javax.naming.Context;
import java.util.Properties;
import javax.mail.Multipart;
import org.slf4j.LoggerFactory;
import java.io.FileInputStream;
import javax.mail.Authenticator;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import javax.mail.Message.RecipientType;
import javax.mail.PasswordAuthentication;
import org.apache.commons.lang.StringUtils;
import javax.mail.internet.InternetAddress;

import com.cws.esolutions.core.CoreServicesConstants;
import com.cws.esolutions.core.config.xml.MailConfig;
import com.cws.esolutions.core.utils.dto.EmailMessage;
/**
 * Interface for the Application Data DAO layer. Allows access
 * into the asset management database to obtain, modify and remove
 * application information.
 *
 * @author cws-khuntly
 * @version 1.0
 */
public final class EmailUtils
{
    private static final String INIT_DS_CONTEXT = "java:comp/env/";
    private static final String CNAME = EmailUtils.class.getName();

    static final Logger DEBUGGER = LoggerFactory.getLogger(CoreServicesConstants.DEBUGGER);
    static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    static final Logger ERROR_RECORDER = LoggerFactory.getLogger(CoreServicesConstants.ERROR_LOGGER + CNAME);

    /**
     * eSolutionsCore
     * com.cws.esolutions.core.utils
     * EmailUtils.java$SMTPAuthenticator
     *
     * Inner class performing extending <code>Authenticator</code> This will
     * be utilized when authentication is required to the specified SMTP
     * server, as configured.
     *
     * $Id: $
     * $Author: $
     * $Date: $
     * $Revision: $
     * @author cws-khuntly
     * @version 1.0
     *
     * History
     * ----------------------------------------------------------------------------
     * cws-khuntly @ Dec 26, 2012 12:54:17 PM
     *     Created.
     */
    public static final class SMTPAuthenticator extends Authenticator
    {
        static final String CNAME = SMTPAuthenticator.class.getName();

        /**
         * Returns an instance of PasswordAuthentication to provide
         * an authentication mechanism for a target SMTP server
         *
         * @param userName - The username to utilize
         * @param password - The password to utilize
         * @return PasswordAuthentication - The password authentication object
         */
        public static final synchronized PasswordAuthentication getPasswordAuthentication(final String userName, final String password)
        {
            final String methodName = SMTPAuthenticator.CNAME + "#getPasswordAuthentication(final String userName, final String password)";

            if (DEBUG)
            {
                DEBUGGER.debug(methodName);
                DEBUGGER.debug(userName);
                DEBUGGER.debug(password);
            }

            return new PasswordAuthentication(userName, password);
        }
    }

    /**
     * Processes and sends an email message as generated by the requesting
     * application. This method is utilized with a JNDI datasource.
     *
     * @param mailConfig - The {@link com.cws.esolutions.core.config.xml.MailConfig} to utilize
     * @param message - The email message
     * @param isWeb - <code>true</code> if this came from a container, <code>false</code> otherwise
     * @throws MessagingException {@link javax.mail.MessagingException} if an exception occurs sending the message
     */
    public static final synchronized void sendEmailMessage(final MailConfig mailConfig, final EmailMessage message, final boolean isWeb) throws MessagingException
    {
        final String methodName = EmailUtils.CNAME + "#sendEmailMessage(final MailConfig mailConfig, final EmailMessage message, final boolean isWeb) throws MessagingException";

        Session mailSession = null;

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", mailConfig);
            DEBUGGER.debug("Value: {}", message);
            DEBUGGER.debug("Value: {}", isWeb);
        }

        SMTPAuthenticator smtpAuth = null;

        if (DEBUG)
        {
            DEBUGGER.debug("MailConfig: {}", mailConfig);
        }

        try
        {
            if (isWeb)
            {
                Context initContext = new InitialContext();

                if (DEBUG)
                {
                    DEBUGGER.debug("InitialContext: {}", initContext);
                }

                if (initContext != null)
                {
                    mailSession = (Session) initContext.lookup(mailConfig.getDataSourceName());
                }
            }
            else
            {
                Properties mailProps = new Properties();

                try
                {
                    mailProps.load(EmailUtils.class.getClassLoader().getResourceAsStream(mailConfig.getPropertyFile()));
                }
                catch (final NullPointerException npx)
                {
                    try
                    {
                        mailProps.load(new FileInputStream(mailConfig.getPropertyFile()));
                    }
                    catch (final IOException iox)
                    {
                        throw new MessagingException(iox.getMessage(), iox);
                    }
                }
                catch (final IOException iox)
                {
                    throw new MessagingException(iox.getMessage(), iox);
                }

                if (DEBUG)
                {
                    DEBUGGER.debug("Properties: {}", mailProps);
                }

                if (StringUtils.equals((String) mailProps.get("mail.smtp.auth"), "true"))
                {
                    smtpAuth = new SMTPAuthenticator();
                    mailSession = Session.getDefaultInstance(mailProps, smtpAuth);
                }
                else
                {
                    mailSession = Session.getDefaultInstance(mailProps);
                }
            }

            if (DEBUG)
            {
                DEBUGGER.debug("Session: {}", mailSession);
            }

            if (mailSession == null)
            {
                throw new MessagingException("Unable to configure email services");
            }

            mailSession.setDebug(DEBUG);
            MimeMessage mailMessage = new MimeMessage(mailSession);

            // Our emailList parameter should contain the following
            // items (in this order):
            // 0. Recipients
            // 1. From Address
            // 2. Generated-From (if blank, a default value is used)
            // 3. The message subject
            // 4. The message content
            // 5. The message id (optional)
            // We're only checking to ensure that the 'from' and 'to'
            // values aren't null - the rest is really optional.. if
            // the calling application sends a blank email, we aren't
            // handing it here.
            if (message.getMessageTo().size() != 0)
            {
                for (String to : message.getMessageTo())
                {
                    if (DEBUG)
                    {
                        DEBUGGER.debug(to);
                    }

                    mailMessage.setRecipient(Message.RecipientType.TO, new InternetAddress(to));
                }

                mailMessage.setFrom(new InternetAddress(message.getEmailAddr().get(0)));
                mailMessage.setSubject(message.getMessageSubject());
                mailMessage.setContent(message.getMessageBody(), "text/html");

                if (message.isAlert())
                {
                    mailMessage.setHeader("Importance", "High");
                }

                Transport mailTransport = mailSession.getTransport("smtp");

                if (DEBUG)
                {
                    DEBUGGER.debug("Transport: {}", mailTransport);
                }

                mailTransport.connect();

                if (mailTransport.isConnected())
                {
                    Transport.send(mailMessage);
                }
            }
        }
        catch (final MessagingException mex)
        {
            throw new MessagingException(mex.getMessage(), mex);
        }
        catch (final NamingException nx)
        {
            throw new MessagingException(nx.getMessage(), nx);
        }
    }

    /**
     * Processes and sends an email message as generated by the requesting
     * application. This method is utilized with a JNDI datasource.
     *
     * @param dataSource - The email message
     * @param authRequired - <code>true</code> if authentication is required, <code>false</code> otherwise
     * @param authList - If authRequired is true, this must be populated with the auth info
     * @return List - The list of email messages in the mailstore
     * @throws MessagingException {@link javax.mail.MessagingException} if an exception occurs during processing
     */
    public static final synchronized List<EmailMessage> readEmailMessages(final Properties dataSource, final boolean authRequired, final List<String> authList) throws MessagingException
    {
        final String methodName = EmailUtils.CNAME + "#readEmailMessages(final Properties dataSource, final boolean authRequired, final List<String> authList) throws MessagingException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("dataSource: {}", dataSource);
            DEBUGGER.debug("authRequired: {}", authRequired);
            DEBUGGER.debug("authList: {}", authList);
        }

        Folder mailFolder = null;
        Session mailSession = null;
        Folder archiveFolder = null;
        List<EmailMessage> emailMessages = null;

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.HOUR, -24);

        final Long TIME_PERIOD = cal.getTimeInMillis();
        final URLName URL_NAME = (authRequired) ? new URLName(dataSource.getProperty("mailtype"), dataSource.getProperty("host"),
                Integer.parseInt(dataSource.getProperty("port")), null, authList.get(0), authList.get(1))
                : new URLName(dataSource.getProperty("mailtype"), dataSource.getProperty("host"),
                        Integer.parseInt(dataSource.getProperty("port")), null, null, null);

        if (DEBUG)
        {
            DEBUGGER.debug("timePeriod: {}", TIME_PERIOD);
            DEBUGGER.debug("URL_NAME: {}", URL_NAME);
        }

        try
        {
            // Set up mail session
            mailSession = (authRequired) ? Session.getDefaultInstance(dataSource, new SMTPAuthenticator()) : Session.getDefaultInstance(dataSource);

            if (DEBUG)
            {
                DEBUGGER.debug("mailSession: {}", mailSession);
            }

            if (mailSession == null)
            {
                throw new MessagingException("Unable to configure email services");
            }

            mailSession.setDebug(DEBUG);
            Store mailStore = mailSession.getStore(URL_NAME);
            mailStore.connect();

            if (DEBUG)
            {
                DEBUGGER.debug("mailStore: {}", mailStore);
            }

            if (!(mailStore.isConnected()))
            {
                throw new MessagingException("Failed to connect to mail service. Cannot continue.");
            }

            mailFolder = mailStore.getFolder("inbox");
            archiveFolder = mailStore.getFolder("archive");

            if (!(mailFolder.exists()))
            {
                throw new MessagingException("Requested folder does not exist. Cannot continue.");
            }

            mailFolder.open(Folder.READ_WRITE);

            if ((!(mailFolder.isOpen())) || (!(mailFolder.hasNewMessages())))
            {
                throw new MessagingException("Failed to open requested folder. Cannot continue");
            }

            if (!(archiveFolder.exists()))
            {
                archiveFolder.create(Folder.HOLDS_MESSAGES);
            }

            Message[] mailMessages = mailFolder.getMessages();

            if (mailMessages.length == 0)
            {
                throw new MessagingException("No messages were found in the provided store.");
            }

            emailMessages = new ArrayList<EmailMessage>();

            for (Message message : mailMessages)
            {
                if (DEBUG)
                {
                    DEBUGGER.debug("MailMessage: {}", message);
                }

                // validate the message here
                String messageId = message.getHeader("Message-ID")[0];
                Long messageDate = message.getReceivedDate().getTime();

                if (DEBUG)
                {
                    DEBUGGER.debug("messageId: {}", messageId);
                    DEBUGGER.debug("messageDate: {}", messageDate);
                }

                // only get emails for the last 24 hours
                // this should prevent us from pulling too
                // many emails
                if (messageDate >= TIME_PERIOD)
                {
                    // process it
                    Multipart attachment = (Multipart) message.getContent();
                    Map<String, InputStream> attachmentList = new HashMap<String, InputStream>();

                    for (int x = 0; x < attachment.getCount(); x++)
                    {
                        BodyPart bodyPart = attachment.getBodyPart(x);

                        if (!(Part.ATTACHMENT.equalsIgnoreCase(bodyPart.getDisposition())))
                        {
                            continue;
                        }

                        attachmentList.put(bodyPart.getFileName(), bodyPart.getInputStream());
                    }

                    List<String> toList = new ArrayList<String>();
                    List<String> ccList = new ArrayList<String>();
                    List<String> bccList = new ArrayList<String>();
                    List<String> fromList = new ArrayList<String>();

                    for (Address from : message.getFrom())
                    {
                        fromList.add(from.toString());
                    }

                    if ((message.getRecipients(RecipientType.TO) != null) && (message.getRecipients(RecipientType.TO).length != 0))
                    {
                        for (Address to : message.getRecipients(RecipientType.TO))
                        {
                            toList.add(to.toString());
                        }
                    }

                    if ((message.getRecipients(RecipientType.CC) != null) && (message.getRecipients(RecipientType.CC).length != 0))
                    {
                        for (Address cc : message.getRecipients(RecipientType.CC))
                        {
                            ccList.add(cc.toString());
                        }
                    }

                    if ((message.getRecipients(RecipientType.BCC) != null) && (message.getRecipients(RecipientType.BCC).length != 0))
                    {
                        for (Address bcc : message.getRecipients(RecipientType.BCC))
                        {
                            bccList.add(bcc.toString());
                        }
                    }

                    EmailMessage emailMessage = new EmailMessage();
                    emailMessage.setMessageTo(toList);
                    emailMessage.setMessageCC(ccList);
                    emailMessage.setMessageBCC(bccList);
                    emailMessage.setEmailAddr(fromList);
                    emailMessage.setMessageAttachments(attachmentList);
                    emailMessage.setMessageDate(message.getSentDate());
                    emailMessage.setMessageSubject(message.getSubject());
                    emailMessage.setMessageBody(message.getContent().toString());
                    emailMessage.setMessageSources(message.getHeader("Received"));

                    if (DEBUG)
                    {
                        DEBUGGER.debug("emailMessage: {}", emailMessage);
                    }

                    emailMessages.add(emailMessage);

                    if (DEBUG)
                    {
                        DEBUGGER.debug("emailMessages: {}", emailMessages);
                    }
                }

                // archive it
                archiveFolder.open(Folder.READ_WRITE);

                if (archiveFolder.isOpen())
                {
                    mailFolder.copyMessages(new Message[] { message }, archiveFolder);
                    message.setFlag(Flags.Flag.DELETED, true);
                }
            }
        }
        catch (final IOException iox)
        {
            throw new MessagingException(iox.getMessage(), iox);
        }
        catch (final MessagingException mex)
        {
            throw new MessagingException(mex.getMessage(), mex);
        }
        finally
        {
            try
            {
                if ((mailFolder != null) && (mailFolder.isOpen()))
                {
                    mailFolder.close(true);
                }

                if ((archiveFolder != null) && (archiveFolder.isOpen()))
                {
                    archiveFolder.close(false);
                }
            }
            catch (final MessagingException mx)
            {
                ERROR_RECORDER.error(mx.getMessage(), mx);
            }
        }

        return emailMessages;
    }
}
