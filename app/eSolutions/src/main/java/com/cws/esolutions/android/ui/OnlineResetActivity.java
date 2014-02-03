/*
 * Copyright (c) 2009 - 2014 CaspersBox Web Services
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
package com.cws.esolutions.android.ui;
/*
 * eSolutions
 * com.cws.esolutions.core.ui
 * OnlineResetActivity.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import org.slf4j.Logger;
import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.widget.TextView;
import org.slf4j.LoggerFactory;

import com.cws.esolutions.android.Constants;
import com.cws.esolutions.security.dto.UserAccount;
/**
 * Interface for the Application Data DAO layer. Allows access
 * into the asset management database to obtain, modify and remove
 * application information.
 *
 * @author khuntly
 * @version 1.0
 * @see android.app.Activity
 */
public class OnlineResetActivity extends Activity
{
    private static final String CNAME = OnlineResetActivity.class.getName();
    private static final Logger DEBUGGER = LoggerFactory.getLogger(Constants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();

    public void onCreate(final Bundle bundle)
    {
        final String methodName = OnlineResetActivity.CNAME + "#onCreate(final Bundle bundle)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Bundle: {}", bundle);
        }

        super.onCreate(bundle);
        super.setTitle(R.string.mainTitle);
        super.setContentView(R.layout.onlinereset);

        final UserAccount userAccount = (UserAccount) super.getIntent().getExtras().getSerializable(Constants.USER_DATA);

        if (DEBUG)
        {
            DEBUGGER.debug("UserAccount: {}", userAccount);
        }

        if (userAccount == null)
        {
            // no user, die
            this.startActivity(new Intent(this, LoginActivity.class));
            super.finish();
        }
        else
        {
            TextView showWelcome = (TextView) findViewById(R.id.tvShowWelcome);
            showWelcome.setText("Welcome, " + userAccount.getDisplayName());

            if (DEBUG)
            {
                DEBUGGER.debug("TextView: {}", showWelcome);
            }
        }
    }

    @Override
    public void onBackPressed()
    {
        final String methodName = OnlineResetActivity.CNAME + "#onBackPressed()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        // do signout here
        this.startActivity(new Intent(this, LoginActivity.class));
        super.finish();
    }
}